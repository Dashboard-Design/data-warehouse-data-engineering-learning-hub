import os
import sys
import petl
import petl.io.xlsx
import pymssql
import configparser
import requests
import datetime
import json
import decimal


# get data from configration file 
config = configparser.ConfigParser()
try:
    config.read('ETLDemo.ini')
except Exception as e: 
    print('Could not read configuration file: ' + str(e))    
    sys.exit()

# read setting from configuration file
startDate = config['CONFIG']['startDate']
url = config['CONFIG']['url']
destserver = config['CONFIG']['server']
destdatabase = config['CONFIG']['database']

# request data from URL
try:
    BOCResponse = requests.get(url + startDate)
except Exception as e:
    print('could not make request' + str(e) )
    sys.exit()

# initialize list of lists for data storage
BOCDates = []
BOCRates = []

# check response status and process BOC JSOM object
if ( BOCResponse.status_code == 200):
    BOCRaw = json.loads(BOCResponse.text)

    for row in BOCRaw['observations']:
        BOCDates.append(datetime.datetime.strptime(row['d'],'%Y-%m-%d') )
        BOCRates.append(decimal.Decimal(row['FXUSDCAD']['v']) )

    # create petl table from column arrays and rename the columns --- petl
    exchangeRates = petl.fromcolumns([BOCDates,BOCRates], header=['date', 'rate'])

    try:
        expenses = petl.io.xlsx.fromxlsx('Expenses.xlsx', sheet='Github')
    except Exception as e:
        print('could not open expenses.xlsx' + str(e))
        sys.exit()

    # join tables 
    expenses = petl.outerjoin(exchangeRates, expenses, key='date')

    # fill down missing values
    expenses = petl.filldown(expenses, 'rate')

    # remove dates with no expenses
    expenses = petl.select(expenses, lambda rec: rec.USD != None)

    # addind Canadian dollars column, CND column
    expenses = petl.addfield(expenses, 'CAD', lambda rec: decimal.Decimal(rec.USD) * rec.rate )


    # initializing database connection
    try:
        dbconnection = pymssql.connect(server= destserver, database= destdatabase)
    except Exception as e:
        print('could not connect to database:' + str(e))
        sys.exit()


    # populate Expenses database tale
    try:
        petl.io.todb( expenses, dbconnection, 'Expenses')
    except Exception as e:
        print('could not write to database:' + str(e) )