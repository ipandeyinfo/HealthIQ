import re

f = r'c:\Users\AshishPandey\OneDrive - Federation University Australia\Desktop\IQ\index.html'
content = open(f, 'r', encoding='utf-8').read()

# Fix stat-change arrows (orphan single quotes used as up-arrow)
content = content.replace("stat-change\">' ", "stat-change\">↑ ")

# Fix "Google Drive image" instruction arrow
content = content.replace("' Anyone with link '", "→ Anyone with link →")

# Write back
open(f, 'w', encoding='utf-8', newline='').write(content)
print("Done - second pass fixes applied")
