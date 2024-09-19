import ftplib
import csv

# Function to download Nasdaq-listed companies from FTP
def download_nasdaq_data():
    ftp = ftplib.FTP('ftp.nasdaqtrader.com')
    ftp.login()  # Anonymous login
    
    # Change to the directory containing symbol data
    ftp.cwd('SymbolDirectory')
    
    # Files to download from Nasdaq FTP
    files_to_download = ['nasdaqlisted.txt', 'otherlisted.txt']
    downloaded_data = []
    
    for filename in files_to_download:
        # Download file and store its contents
        with open(filename, 'wb') as local_file:
            ftp.retrbinary(f'RETR {filename}', local_file.write)
        # Read the downloaded file
        with open(filename, 'r') as local_file:
            downloaded_data.append(local_file.readlines())
    
    ftp.quit()
    
    return downloaded_data

# Function to parse Nasdaq-listed companies and save to CSV
def parse_nasdaq_data(nasdaq_data):
    # nasdaqlisted.txt has a different format than otherlisted.txt
    nasdaqlisted = nasdaq_data[0]
    otherlisted = nasdaq_data[1]
    
    nasdaq_companies = []
    
    # Parse nasdaqlisted.txt
    for line in nasdaqlisted:
        if "|" in line and "Symbol" not in line:  # Skip header
            parts = line.split("|")
            symbol = parts[0].strip()
            name = parts[1].strip()
            exchange = 'Nasdaq'
            nasdaq_companies.append([symbol, name, exchange])
    
    # Parse otherlisted.txt
    for line in otherlisted:
        if "|" in line and "ACT Symbol" not in line:  # Skip header
            parts = line.split("|")
            symbol = parts[0].strip()
            name = parts[1].strip()
            exchange = parts[2].strip()
            nasdaq_companies.append([symbol, name, exchange])
    
    return nasdaq_companies

# Function to save parsed data to CSV
def save_to_csv(companies, filename='nasdaq_companies.csv'):
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(["Symbol", "Name", "Exchange"])  # Header
        writer.writerows(companies)
    print(f"Data successfully saved to {filename}")

# Main function
if __name__ == "__main__":
    # Step 1: Download data from Nasdaq FTP
    nasdaq_data = download_nasdaq_data()
    
    # Step 2: Parse the downloaded data
    companies = parse_nasdaq_data(nasdaq_data)
    
    # Step 3: Save the data to CSV
    save_to_csv(companies)
    print(f"Total companies retrieved: {len(companies)}")
