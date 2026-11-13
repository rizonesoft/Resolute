-- The reference-data schema (D00 T06 section 1). MySQL 8.4 LTS; kept to what MariaDB 11 also runs: InnoDB, no JSON
-- columns, no generated columns. Run into an empty database with the mysql client (it reads the DELIMITER lines).
--
-- A dataset is one family of data (BiosCodes' beep codes will be one). An entry is one item in it, named by a key that
-- is stable: never reused, never renamed, whatever its text becomes. Its text is a meaning, and every version that
-- changes the text adds a meaning, so an older version's text stays readable. A version is proposed, then reviewed
-- by someone other than its author, then stamped; only a proposed version can change, a reviewed one is frozen, and
-- reopen takes it back to proposed and clears its review. Every change and every step writes one changelog row with
-- its reason.
--
-- A step (review, reopen, stamp) runs in one transaction from the client, and its status change applies only to the
-- status it checked, so two authors acting on one version at once cannot both succeed on a stale reading.
--
-- The workflow's rules are here, in the procedures, and each refusal is a SIGNAL whose text names it, so no client
-- can step around them. A proposal of several changes runs in one transaction in one client session: a refused change
-- leaves no row of the others.
--
-- Revision 2 (D00 T06 section 1, Repair 1): the schema records its revision, every add and reword keeps the text and
-- source it set in its changelog row, and a review names the digest of the contents its reviewer inspected, which the
-- database compares under the version's lock. A database at revision 1 is moved here with refdata.py upgrade.

CREATE TABLE schema_info (
    revision INT UNSIGNED NOT NULL PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO schema_info (revision) VALUES (2);

CREATE TABLE datasets (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    description VARCHAR(500) NOT NULL,
    UNIQUE KEY datasets_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE versions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    dataset_id INT UNSIGNED NOT NULL,
    number INT UNSIGNED NOT NULL,
    status ENUM('proposed', 'reviewed', 'stamped') NOT NULL DEFAULT 'proposed',
    author VARCHAR(100) NOT NULL,
    reviewer VARCHAR(100) NULL,
    opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    stamped_at DATETIME NULL,
    UNIQUE KEY versions_number (dataset_id, number),
    CONSTRAINT versions_dataset FOREIGN KEY (dataset_id) REFERENCES datasets (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE entries (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    dataset_id INT UNSIGNED NOT NULL,
    entry_key VARCHAR(64) NOT NULL,
    created_version_id INT UNSIGNED NOT NULL,
    UNIQUE KEY entries_key (dataset_id, entry_key),
    CONSTRAINT entries_dataset FOREIGN KEY (dataset_id) REFERENCES datasets (id),
    CONSTRAINT entries_version FOREIGN KEY (created_version_id) REFERENCES versions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sources (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    citation VARCHAR(500) NOT NULL,
    UNIQUE KEY sources_citation (citation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE meanings (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    entry_id INT UNSIGNED NOT NULL,
    version_id INT UNSIGNED NOT NULL,
    text VARCHAR(2000) NOT NULL,
    source_id INT UNSIGNED NULL,
    UNIQUE KEY meanings_entry_version (entry_id, version_id),
    CONSTRAINT meanings_entry FOREIGN KEY (entry_id) REFERENCES entries (id),
    CONSTRAINT meanings_version FOREIGN KEY (version_id) REFERENCES versions (id),
    CONSTRAINT meanings_source FOREIGN KEY (source_id) REFERENCES sources (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE changelog (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    version_id INT UNSIGNED NOT NULL,
    entry_id INT UNSIGNED NULL,
    action ENUM('open', 'add', 'reword', 'review', 'reopen', 'stamp') NOT NULL,
    reason VARCHAR(1000) NOT NULL,
    actor VARCHAR(100) NOT NULL,
    at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- What an add or reword set. A row written before revision 2 has contents_recorded 0: its contents were not kept.
    text VARCHAR(2000) NULL,
    source VARCHAR(500) NULL,
    contents_recorded TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT changelog_version FOREIGN KEY (version_id) REFERENCES versions (id),
    CONSTRAINT changelog_entry FOREIGN KEY (entry_id) REFERENCES entries (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

CREATE PROCEDURE rd_require_reason (IN p_reason VARCHAR(1000))
BEGIN
    IF p_reason IS NULL OR TRIM(p_reason) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: a change needs a reason';
    END IF;
END //

CREATE PROCEDURE rd_dataset_id (IN p_dataset VARCHAR(64), OUT p_id INT UNSIGNED)
BEGIN
    SET p_id = NULL;
    SELECT id INTO p_id FROM datasets WHERE name = p_dataset;
    IF p_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: no such dataset';
    END IF;
END //

CREATE PROCEDURE rd_version (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, OUT p_version INT UNSIGNED, OUT p_status VARCHAR(10), OUT p_author VARCHAR(100))
BEGIN
    DECLARE v_dataset INT UNSIGNED;
    CALL rd_dataset_id(p_dataset, v_dataset);
    SET p_version = NULL;
    SELECT id, status, author INTO p_version, p_status, p_author FROM versions WHERE dataset_id = v_dataset AND number = p_number FOR UPDATE;
    IF p_version IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: no such version';
    END IF;
END //

CREATE PROCEDURE rd_require_proposed (IN p_status VARCHAR(10))
BEGIN
    IF p_status = 'stamped' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version is stamped and cannot change';
    ELSEIF p_status = 'reviewed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version is reviewed and frozen; reopen it to change it';
    END IF;
END //

CREATE PROCEDURE rd_source_id (IN p_citation VARCHAR(500), OUT p_id INT UNSIGNED)
BEGIN
    SET p_id = NULL;
    IF p_citation IS NOT NULL AND TRIM(p_citation) <> '' THEN
        INSERT IGNORE INTO sources (citation) VALUES (p_citation);
        SELECT id INTO p_id FROM sources WHERE citation = p_citation;
    END IF;
END //

CREATE PROCEDURE rd_create_dataset (IN p_dataset VARCHAR(64), IN p_description VARCHAR(500))
BEGIN
    IF EXISTS (SELECT 1 FROM datasets WHERE name = p_dataset) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the dataset already exists';
    END IF;
    INSERT INTO datasets (name, description) VALUES (p_dataset, p_description);
END //

-- Opens the next version of a dataset. Only one version is open (proposed or reviewed) at a time.
CREATE PROCEDURE rd_open_version (IN p_dataset VARCHAR(64), IN p_author VARCHAR(100), IN p_reason VARCHAR(1000))
BEGIN
    DECLARE v_dataset INT UNSIGNED;
    DECLARE v_next INT UNSIGNED;
    CALL rd_require_reason(p_reason);
    CALL rd_dataset_id(p_dataset, v_dataset);
    IF EXISTS (SELECT 1 FROM versions WHERE dataset_id = v_dataset AND status <> 'stamped') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the dataset already has an open version';
    END IF;
    SELECT COALESCE(MAX(number), 0) + 1 INTO v_next FROM versions WHERE dataset_id = v_dataset;
    INSERT INTO versions (dataset_id, number, author) VALUES (v_dataset, v_next, p_author);
    INSERT INTO changelog (version_id, action, reason, actor) VALUES (LAST_INSERT_ID(), 'open', p_reason, p_author);
END //

CREATE PROCEDURE rd_add (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, IN p_key VARCHAR(64), IN p_text VARCHAR(2000), IN p_source VARCHAR(500), IN p_reason VARCHAR(1000), IN p_actor VARCHAR(100))
BEGIN
    DECLARE v_version INT UNSIGNED;
    DECLARE v_status VARCHAR(10);
    DECLARE v_author VARCHAR(100);
    DECLARE v_dataset INT UNSIGNED;
    DECLARE v_source INT UNSIGNED;
    DECLARE v_entry INT UNSIGNED;
    CALL rd_require_reason(p_reason);
    CALL rd_version(p_dataset, p_number, v_version, v_status, v_author);
    CALL rd_require_proposed(v_status);
    CALL rd_dataset_id(p_dataset, v_dataset);
    IF EXISTS (SELECT 1 FROM entries WHERE dataset_id = v_dataset AND entry_key = p_key) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the key is already used in this dataset; keys are never reused';
    END IF;
    CALL rd_source_id(p_source, v_source);
    INSERT INTO entries (dataset_id, entry_key, created_version_id) VALUES (v_dataset, p_key, v_version);
    SET v_entry = LAST_INSERT_ID();
    INSERT INTO meanings (entry_id, version_id, text, source_id) VALUES (v_entry, v_version, p_text, v_source);
    INSERT INTO changelog (version_id, entry_id, action, reason, actor, text, source, contents_recorded) VALUES (v_version, v_entry, 'add', p_reason, p_actor, p_text, p_source, 1);
END //

CREATE PROCEDURE rd_reword (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, IN p_key VARCHAR(64), IN p_text VARCHAR(2000), IN p_source VARCHAR(500), IN p_reason VARCHAR(1000), IN p_actor VARCHAR(100))
BEGIN
    DECLARE v_version INT UNSIGNED;
    DECLARE v_status VARCHAR(10);
    DECLARE v_author VARCHAR(100);
    DECLARE v_dataset INT UNSIGNED;
    DECLARE v_source INT UNSIGNED;
    DECLARE v_entry INT UNSIGNED;
    CALL rd_require_reason(p_reason);
    CALL rd_version(p_dataset, p_number, v_version, v_status, v_author);
    CALL rd_require_proposed(v_status);
    CALL rd_dataset_id(p_dataset, v_dataset);
    SET v_entry = NULL;
    SELECT id INTO v_entry FROM entries WHERE dataset_id = v_dataset AND entry_key = p_key;
    IF v_entry IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: no such key in this dataset';
    END IF;
    CALL rd_source_id(p_source, v_source);
    INSERT INTO meanings (entry_id, version_id, text, source_id) VALUES (v_entry, v_version, p_text, v_source)
        ON DUPLICATE KEY UPDATE text = VALUES(text), source_id = VALUES(source_id);
    INSERT INTO changelog (version_id, entry_id, action, reason, actor, text, source, contents_recorded) VALUES (v_version, v_entry, 'reword', p_reason, p_actor, p_text, p_source, 1);
END //

-- A key is the entry's name for good: there is no rename, and asking for one is refused by name.
CREATE PROCEDURE rd_rename (IN p_dataset VARCHAR(64), IN p_key VARCHAR(64), IN p_new_key VARCHAR(64))
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: keys are never renamed; add a new key and leave the old one';
END //

-- A version's digest: SHA-256 chained over its entries in key order, each key, text and source written with its length
-- so no two contents share one. It covers what `changes` and `show` print of the version, inherited entries included.
CREATE PROCEDURE rd_version_digest (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, OUT p_digest CHAR(64))
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_key VARCHAR(64);
    DECLARE v_text VARCHAR(2000);
    DECLARE v_source VARCHAR(500);
    DECLARE v_rows CURSOR FOR SELECT entry_key, text, source FROM rd_version_text WHERE dataset = p_dataset AND as_of = p_number ORDER BY entry_key;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    SET p_digest = SHA2(CONCAT('refdata digest 1:', CHAR_LENGTH(p_dataset), ':', p_dataset, ':', p_number), 256);
    OPEN v_rows;
    each_row: LOOP
        FETCH v_rows INTO v_key, v_text, v_source;
        IF v_done THEN
            LEAVE each_row;
        END IF;
        SET p_digest = SHA2(CONCAT(p_digest, CHAR_LENGTH(v_key), ':', v_key, CHAR_LENGTH(v_text), ':', v_text,
            IF(v_source IS NULL, '-', CONCAT(CHAR_LENGTH(v_source), ':', v_source))), 256);
    END LOOP;
    CLOSE v_rows;
END //

-- A review approves the contents its reviewer inspected, named by their digest (refdata.py changes prints it). The
-- version row is locked first (rd_version reads it FOR UPDATE, as every edit does), so an edit in flight finishes
-- before the digest is taken, and the digest is taken at READ COMMITTED so it reads what that edit committed rather
-- than the snapshot the transaction began with; a different digest refuses the review.
CREATE PROCEDURE rd_review (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, IN p_reviewer VARCHAR(100), IN p_reason VARCHAR(1000), IN p_inspected CHAR(64))
BEGIN
    DECLARE v_version INT UNSIGNED;
    DECLARE v_status VARCHAR(10);
    DECLARE v_author VARCHAR(100);
    DECLARE v_digest CHAR(64);
    CALL rd_require_reason(p_reason);
    CALL rd_version(p_dataset, p_number, v_version, v_status, v_author);
    IF v_status <> 'proposed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: only a proposed version can be reviewed';
    END IF;
    IF p_reviewer = v_author THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the reviewer is the author';
    END IF;
    -- Anyone who changed the version is one of its authors, whoever opened it.
    IF EXISTS (SELECT 1 FROM changelog WHERE version_id = v_version AND action IN ('open', 'add', 'reword') AND actor = p_reviewer) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the reviewer changed this version';
    END IF;
    IF @@SESSION.transaction_isolation <> 'READ-COMMITTED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: a review runs at READ COMMITTED, so it reads the contents it approves';
    END IF;
    CALL rd_version_digest(p_dataset, p_number, v_digest);
    IF p_inspected IS NULL OR p_inspected <> v_digest THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version changed since it was inspected; run changes again and review what it shows';
    END IF;
    UPDATE versions SET status = 'reviewed', reviewer = p_reviewer WHERE id = v_version AND status = 'proposed';
    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version changed while it was being reviewed';
    END IF;
    INSERT INTO changelog (version_id, action, reason, actor) VALUES (v_version, 'review', p_reason, p_reviewer);
END //

-- Takes a reviewed version back to proposed so it can change again; its review is cleared, so it must be reviewed again.
CREATE PROCEDURE rd_reopen (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, IN p_actor VARCHAR(100), IN p_reason VARCHAR(1000))
BEGIN
    DECLARE v_version INT UNSIGNED;
    DECLARE v_status VARCHAR(10);
    DECLARE v_author VARCHAR(100);
    CALL rd_require_reason(p_reason);
    CALL rd_version(p_dataset, p_number, v_version, v_status, v_author);
    IF v_status <> 'reviewed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: only a reviewed version can be reopened';
    END IF;
    UPDATE versions SET status = 'proposed', reviewer = NULL WHERE id = v_version AND status = 'reviewed';
    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version changed while it was being reopened';
    END IF;
    INSERT INTO changelog (version_id, action, reason, actor) VALUES (v_version, 'reopen', p_reason, p_actor);
END //

CREATE PROCEDURE rd_stamp (IN p_dataset VARCHAR(64), IN p_number INT UNSIGNED, IN p_actor VARCHAR(100), IN p_reason VARCHAR(1000))
BEGIN
    DECLARE v_version INT UNSIGNED;
    DECLARE v_status VARCHAR(10);
    DECLARE v_author VARCHAR(100);
    CALL rd_require_reason(p_reason);
    CALL rd_version(p_dataset, p_number, v_version, v_status, v_author);
    IF v_status = 'stamped' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version is already stamped';
    ELSEIF v_status <> 'reviewed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version is not reviewed';
    END IF;
    UPDATE versions SET status = 'stamped', stamped_at = CURRENT_TIMESTAMP WHERE id = v_version AND status = 'reviewed';
    IF ROW_COUNT() <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'refused: the version changed while it was being stamped';
    END IF;
    INSERT INTO changelog (version_id, action, reason, actor) VALUES (v_version, 'stamp', p_reason, p_actor);
END //

DELIMITER ;

-- The text of every entry as a version has it: for each entry created at or before that version, the meaning from the
-- latest version at or before it. Read it with WHERE dataset = ... AND as_of = ....
CREATE VIEW rd_version_text AS
SELECT d.name AS dataset, v.number AS as_of, e.entry_key, m.text, s.citation AS source, mv.number AS meaning_from
FROM datasets d
JOIN versions v ON v.dataset_id = d.id
JOIN entries e ON e.dataset_id = d.id
JOIN versions ev ON ev.id = e.created_version_id AND ev.number <= v.number
JOIN meanings m ON m.entry_id = e.id
JOIN versions mv ON mv.id = m.version_id AND mv.number <= v.number
LEFT JOIN sources s ON s.id = m.source_id
WHERE mv.number = (
    SELECT MAX(v2.number) FROM meanings m2 JOIN versions v2 ON v2.id = m2.version_id
    WHERE m2.entry_id = e.id AND v2.number <= v.number
);
