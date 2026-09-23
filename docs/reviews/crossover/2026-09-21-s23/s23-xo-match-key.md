# Matcher key (X/Y assignment fixed before the matcher runs)

Rule: X labels the shorter find-list, Y the longer. Stated after the rung
outputs returned (counts 10 vs 18), before the matcher runs; the matcher
never sees this map (isolated stdin-only run), and X/Y are symmetric to the
pairing task, so the assignment cannot bias it.

X = Sol rung (10): X1=A1 X2=A2 X3=C1 X4=C2 X5=C3 X6=I1 X7=I2 X8=I3 X9=I4 X10=R1
Y = Opus rung (18): Y1=A1 Y2=A2 Y3=A3 Y4=A4 Y5=A5 Y6=A6 Y7=C1 Y8=C2 Y9=C3 Y10=C4 Y11=C5 Y12=C6 Y13=I1 Y14=I2 Y15=I3 Y16=I4 Y17=R1 Y18=R2
