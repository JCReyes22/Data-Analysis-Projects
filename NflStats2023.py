# Libraries 

from bs4 import BeautifulSoup as bs
from requests import get
import pandas as pd
import numpy as np
import glob
import os

# Parse HTML

url = "https://www.nfl.com/stats/player-stats/category/passing/2023/post/all/passingyards/desc"
headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
page = get(url, headers=headers)
soup = bs(page.content, 'html.parser')

# Create CSV files from data tables of player stats

csv_files = []

def getStats(url):
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"}
    page = get(url, headers=headers)
    soup = bs(page.content, 'html.parser')

    category = soup.find('h2', class_='nfl-c-content-header__roofline').get_text(strip=True)
    
    table = soup.find('table')
    column_headers = table.find('thead').find_all('a')
    Columns = ([header.get_text() for header in column_headers])
    Columns.insert(0, 'Player')

    player_stats = []

    rows = table.find('tbody').find_all('tr')

    for row in rows:
        stats = []
        cell = row.find_all('td')
        for stat in range(len(cell)):
            stats.append(cell[stat].get_text(strip=True))
        player_stats.append(stats)

    df = pd.DataFrame(player_stats, columns=Columns)
    csv = df.to_csv('NFL{}Stats.csv'.format(category).replace(" ", ""))
    csv_files.append(csv)

# Creating CSVs for all player stat categories

categories = soup.find_all('li', class_='d3-o-tabs__list-item')
'''
for category in categories:
    link = f"{"https://www.nfl.com"}{category.find('a', href=True)['href']}"
    getStats(link)
'''
# Merging CSV files into one Excel Workbook with multiple sheets

directory = 'C:/Users/jacob/OneDrive/Desktop/Projects/NFL Web Scraping Project'
if not os.path.exists(directory):
    os.makedirs(directory)

excel_writer = pd.ExcelWriter(directory + '/NFLStats2023.xlsx', engine='xlsxwriter')
csv_files = glob.glob('*.csv')

for csv_file in csv_files:
    df = pd.read_csv(csv_file)
    sheet_name = csv_file.split('.')[0]
    df.to_excel(excel_writer, sheet_name=sheet_name, index=False)

excel_writer.close()
