import random
import datetime
from datetime import timedelta
import pandas as pd

fs = open("Supply.txt", 'w')
fc = open("Company.txt", 'w')
fd = open("Date.txt", 'w')
fp = open("Product.txt", 'w')
ff = open("Fact.txt", 'w')

# Supply
print('Start filling Supply table')
f = open("/home/egor/PracDB/names", 'r')
names = f.readlines()
names = [l.rstrip('\n') for l in names]
f.close()
f = open("/home/egor/PracDB/streets", 'r')
streets = f.readlines()
streets = [l.rstrip('\n') for l in streets]
f.close()
f = open("/home/egor/PracDB/comments", 'r')
comments = f.readlines()
comments = [l.rstrip('\n') for l in comments]
f.close()
for i in range(1000000):                # 1 000 000
    print(str(i) + '\t' + names[i % 10026] + '\t' + '{"street": "' + streets[i % 4596] +
          '", "building": "' + str(random.randint(1, 45)) + '"}' + '\t' + comments[random.randint(0, 40)], file=fs)
print('End filling Supply table\n')

# Product
print('Start filling Product table')
f = open('/home/egor/PracDB/Instruments', 'r')
instruments = f.readlines()
instruments = [l.rstrip('\n') for l in instruments]
f.close()
for i in range(len(instruments)):   # 458
    print(str(i) + '\t' + instruments[i] + '\t' + 'шт', file=fp)
print('End filling Product table\n')

# Company
print('Start filling Company table')
stores = ['220 вольт', 'Аксон', 'Домовой', 'Евродом', 'ИКЕА', 'Касторама', 'Колорлон', 'Ларес', 'Леонардо',
          'Леруа Мерлен', 'Максидом', 'Метизы', 'Наш Дом', 'ОБИ', 'Парад Планет', 'Петрович', 'Порядок', 'Сатурн',
          'Строительный двор', 'Стройландия', 'Твой дом', 'ТехноНИКОЛЬ', 'Торговый дом 7', 'Уютерра', 'Фактум',
          'Хофф', 'Энтузиаст', 'ЮСК', 'Бауцентр', 'Мегастрой', 'ВИМОС', 'Протэк', 'Стройпарк', 'Декорадо',
          'Апельсин', 'Все Инструменты']

for i in range(len(stores)*4):      # 144
    print(str(i) + '\t' + stores[i % len(stores)] + '\t' + 'Москва' + '\t' + '{"street": "' +
          streets[random.randint(0, 4095)] + '", "building": "' + str(random.randint(1, 90)) + '"}', file=fc)
print('End filling Company table\n')

# Date
print('Start filling Date table')
date = datetime.date(1995, 7, 17)
for i in range(10000):              # 10 000
    fordate = date + timedelta(days=i)
    print(str(i) + '\t' + str(fordate) + '\t' + str(fordate.year) + '\t' + str(pd.Timestamp(fordate).quarter) +
          '\t' + str(fordate.month) + '\t' + str(fordate.day), file=fd)
print('End filling Date table\n')

# Fact
# Store_ID | Supply_ID | Product_ID | Date_ID | Amount
print('Start filling Fact table')
for i in range(40000000):          # 40 000 000
    print(str(i % 144) + '\t' + str(i % 100000) + '\t' + str(i % 458) + '\t' + str(i % 10000) + '\t' +
          str(random.randint(1, 10)), file=ff)
    if i % 1000000 == 0:
        print(i/1000000)
print('End filling Fact table\n')

fs.close()
fc.close()
fd.close()
fp.close()
ff.close()
print('All files for table filling created!!!')
