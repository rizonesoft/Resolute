namespace SampleApp
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.txtFileName = new System.Windows.Forms.TextBox();
            this.btnSelectIcon = new System.Windows.Forms.Button();
            this.lvwIcons = new System.Windows.Forms.ListView();
            this.iconPickerDialog = new SampleApp.IconPickerDialog();
            this.SuspendLayout();
            // 
            // txtFileName
            // 
            this.txtFileName.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtFileName.Location = new System.Drawing.Point(110, 12);
            this.txtFileName.Name = "txtFileName";
            this.txtFileName.ReadOnly = true;
            this.txtFileName.Size = new System.Drawing.Size(325, 19);
            this.txtFileName.TabIndex = 1;
            // 
            // btnSelectIcon
            // 
            this.btnSelectIcon.Location = new System.Drawing.Point(12, 12);
            this.btnSelectIcon.Name = "btnSelectIcon";
            this.btnSelectIcon.Size = new System.Drawing.Size(92, 19);
            this.btnSelectIcon.TabIndex = 0;
            this.btnSelectIcon.Text = "Select Icon...";
            this.btnSelectIcon.UseVisualStyleBackColor = true;
            this.btnSelectIcon.Click += new System.EventHandler(this.btnPickFile_Click);
            // 
            // lvwIcons
            // 
            this.lvwIcons.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lvwIcons.Location = new System.Drawing.Point(12, 37);
            this.lvwIcons.Name = "lvwIcons";
            this.lvwIcons.OwnerDraw = true;
            this.lvwIcons.Size = new System.Drawing.Size(423, 396);
            this.lvwIcons.TabIndex = 2;
            this.lvwIcons.TileSize = new System.Drawing.Size(132, 130);
            this.lvwIcons.UseCompatibleStateImageBehavior = false;
            this.lvwIcons.View = System.Windows.Forms.View.Tile;
            this.lvwIcons.DrawItem += new System.Windows.Forms.DrawListViewItemEventHandler(this.lvwIcons_DrawItem);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(447, 445);
            this.Controls.Add(this.lvwIcons);
            this.Controls.Add(this.btnSelectIcon);
            this.Controls.Add(this.txtFileName);
            this.Name = "Form1";
            this.Text = "IconExtractor Sample App";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private IconPickerDialog iconPickerDialog;
        private System.Windows.Forms.TextBox txtFileName;
        private System.Windows.Forms.Button btnSelectIcon;
        private System.Windows.Forms.ListView lvwIcons;
    }
}

