(function() {
   ProtoCalendar.LangFile['ja'] = {
     HOUR_MINUTE_ERROR: '時間が無効です。',
     NO_DATE_ERROR: '日を選択して下さい。',
     OK_LABEL: 'OK',
     DEFAULT_FORMAT: 'yyyy/mm/dd',
     LABEL_FORMAT: 'yyyy年mm月dd日 ddddi',
     MONTH_ABBRS: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
     WEEKDAY_ABBRS: ['日','月','火','水','木','金','土'],
     WEEKDAY_NAMES: ['日曜日','月曜日','火曜日','水曜日','木曜日','金曜日','土曜日'],
     YEAR_LABEL: '年',
     MONTH_LABEL: '月',
     YEAR_AND_MONTH: true,
     today: '今日',
     tomorrow: '明日',
     yesterday: '昨日',

     parseDate: function(inputValue) {
       if (inputValue == '一昨日') {
         var d = new Date();
         d.setDate(d.getDate() - 2);
         return d;
       } else if (inputValue == '明後日') {
         var d = new Date();
         d.setDate(d.getDate() + 2);
         return d;
       }
     },

     getHolidays:   function(calendar) {
       var year = calendar.getYear();
       var month = calendar.getMonth();
       var lastDay = calendar.getNumDayOfMonth();

       var temp;
       if (year < 2000) {
         temp = 2213;
       } else {
         temp = 2089;
       }
       var springDay = Math.floor((31 * year + temp)/128) - Math.floor(year/4) + Math.floor(year/100);

       if (year < 2000) {
         temp = 2525;
       } else {
         temp = 2395;
       }
       var autumnDay =  Math.floor((31 * year + temp)/128) - Math.floor(year/4) + Math.floor(year/100);

       var holidays = [];
       var mondayIndex = 0;
       for(var day = 1; day <= lastDay; day++) {
         var dayOfWeek = new Date(year, month, day).getDay();
         holidays[day] = 0;

         if (dayOfWeek == ProtoCalendar.MONDAY) {
           ++mondayIndex;
         }
        
         /*祝日は削除するためにコメントアウト Edit by ymatsumoto
         if (day == 1 && month == ProtoCalendar.JAN && 1949 <= year) {
           holidays[day] = '元旦';
         } else if (day == 15 && month == ProtoCalendar.JAN && 1949 <= year && year < 2000) {
           holidays[day] = '成人の日';
         } else if (dayOfWeek == ProtoCalendar.MONDAY && mondayIndex == 2 && month == 0 && 2000 <= year) {
           holidays[day] = '成人の日';
         } else if (day == 11 && month == ProtoCalendar.FEB && 1967 <= year) {
           holidays[day] = '建国記念の日';
         } else if (day == springDay && month == ProtoCalendar.MAR) {
           holidays[day] = '春分の日';
         } else if (day == 29 && month == ProtoCalendar.APR && 1989 <= year && year < 2007) {
           holidays[day] = 'みどりの日';
         } else if (day == 29 && month == ProtoCalendar.APR && 1949 <= year && year < 1989) {
           holidays[day] = '天皇誕生日';
         } else if (day == 4 && month == ProtoCalendar.MAY && 2007 <= year) {
           holidays[day] = 'みどりの日';
         } else if (day == 29 && month == ProtoCalendar.APR && 2007 <= year){
           holidays[day] = '昭和の日';
         } else if (day == 3 && month == ProtoCalendar.MAY && 1949 <= year) {
           holidays[day] = '憲法記念日';
         } else if (day == 4 && month == ProtoCalendar.MAY && 1986 <= year && year < 2007) {
           holidays[day] = '国民の休日';
         } else if (day == 5 && month == ProtoCalendar.MAY && 1949 <= year) {
           holidays[day] = 'こどもの日';
         } else if (day == 20 && month == ProtoCalendar.JULY && 1996 <= year && year < 2003) {
           holidays[day] = '海の日';
         } else if (mondayIndex == 3 && month == ProtoCalendar.JULY && dayOfWeek == ProtoCalendar.MONDAY && 2003 <= year) {
           holidays[day] = '海の日';
         } else if (day == 15 && month == ProtoCalendar.SEPT && 1966 <= year && year < 2003) {
           holidays[day] = '敬老の日';
         } else if (mondayIndex == 3 && month == ProtoCalendar.SEPT && dayOfWeek == ProtoCalendar.MONDAY && 2003 <= year) {
           holidays[day] = '敬老の日';
         } else if (autumnDay == day && month == ProtoCalendar.SEPT) {
           holidays[day] = '秋分の日';
         } else if (day == 10 && month == ProtoCalendar.OCT && 1966 <= year && year < 2001) {
           holidays[day] = '体育の日';
         } else if (mondayIndex == 2 && month == ProtoCalendar.OCT && dayOfWeek == ProtoCalendar.MONDAY && 2000 <= year) {
           holidays[day] = '体育の日';
         } else if (day == 3 && month == ProtoCalendar.NOV && 1948 <= year) {
           holidays[day] = '文化の日';
         } else if (day == 23 && month == ProtoCalendar.NOV && 1948 <= year) {
           holidays[day] = '勤労感謝の日';
         } else if (day == 23 && month == ProtoCalendar.DEC && 1989 <= year) {
           holidays[day] = '天皇誕生日';
         }
       }
       var hasHoliday = year > 1973 || year == 1973 && month > ProtoCalendar.APR;
       var hasKokuminHoliday = year >= 1988;
       var oldRule = hasHoliday && year < 2006;
       var curRule = hasHoliday && year >= 2006;
       for(var day = 1; day <= lastDay; day++) {
         var dayOfWeek = new Date(year, month, day).getDay();
         if (hasHoliday) {
           if (dayOfWeek == ProtoCalendar.SUNDAY && holidays[day]) {
             var next = day + 1;
             if (oldRule) {
                if (holidays[next]) continue;
             } else if (curRule) {
               for (; holidays[next]; next += 1) { }
             }
             holidays[next] = '振替休日';
           
           } else if (hasKokuminHoliday && holidays[day - 1] && holidays[day + 1] && !holidays[day]) {
             holidays[day] = '国民の休日';
           }
          }*/
       }
       calendar.holidays = holidays;
     }
   };

 })();
