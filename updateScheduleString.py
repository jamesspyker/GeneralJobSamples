# This example moves the schedule ahead one hour for a job scheduled to run either daily or weekly
import sys
li = list(sys.argv[1].split(" "))

# For readability, use constants to define the elements in the list
minute=0
hour=1
dayOfMonth=2
month=3
dayOfWeek= 4

# Move the hour ahead one, rolling back to midnight if that moves it to the next day
li[hour] =(int(li[hour])+1) % 24

#If there is a day set and we moved it to the next day with the hour, then need to move the day ahead as well
if li[dayOfWeek] != '*':
    if int(li[hour]) == 0:
        li[dayOfWeek] = (int(li[dayOfWeek])+1) % 7

#output the updated schedule string
print (li[minute],li[hour],li[dayOfMonth],li[month],li[dayOfWeek])

