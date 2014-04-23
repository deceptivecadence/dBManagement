import re
import mechanize
import csv
from bs4 import BeautifulSoup


base_url = "http://darksouls.wikidot.com/"
boss_url = "http://darksouls.wikidot.com/bosses"

br = mechanize.Browser()

br.open(boss_url)

soup = BeautifulSoup(br.response().get_data())
bosses = soup.find_all("tr")

header = bosses.pop(0)
header = header.get_text(",", strip=True)

header = header.split(",")
fout = open("bosses.csv","wb")
fout_csv = csv.writer(fout)
fout_csv.writerow(header)

for boss in bosses:
	temp = boss.get_text(",", strip=True).split(",")
	if temp[0] == "Boss":
		break;
	fout_csv.writerow(temp)
#for boss in bosses:


