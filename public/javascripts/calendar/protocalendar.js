/*  protocalendar.js
 *  (c) 2009 Spookies
 * 
 *  License : MIT-style license.
 *  Web site: http://labs.spookies.jp/product/protocalendar
 *
 *  protocalendar.js - depends on prototype.js 1.6 or later
 *  http://www.prototypejs.org/
 *
/*--------------------------------------------------------------------------*/

var ProtoCalendar = Class.create();
ProtoCalendar.Version = "1.1.8.2";

ProtoCalendar.LangFile = new Object();
ProtoCalendar.LangFile['en'] = {
  HOUR_MINUTE_ERROR: 'The time is not valid.',
  NO_DATE_ERROR: 'No day has been selected.',
  OK_LABEL: 'OK',
  DEFAULT_FORMAT: 'mm/dd/yyyy',
  LABEL_FORMAT: 'ddd mm/dd/yyyy',
  MONTH_ABBRS: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
  MONTH_NAMES: ['January','February','March','April','May','June','July','August','September','October','November','December'],
  YEAR_LABEL: ' ',
  MONTH_LABEL: ' ',
  WEEKDAY_ABBRS: ['Sun','Mon','Tue','Wed','Thr','Fri','Sat'],
  WEEKDAY_NAMES: ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
  YEAR_AND_MONTH: false
};

ProtoCalendar.LangFile.defaultLang = 'en';
ProtoCalendar.LangFile.defaultLangFile = function() { return ProtoCalendar.LangFile[defaultLang]; };

ProtoCalendar.newDate = function() {
  var d = new Date();
  d.setDate(1);
  return d;
}

//Only check vertically
ProtoCalendar.withinViewport = function(element) {
  var dimensions = ProtoCalendar.callWithVisibility(element, function() { return element.getDimensions(); });
  var width = dimensions.width;
  var height = dimensions.height;
  var offsets = ProtoCalendar.callWithVisibility(element, function() { return element.viewportOffset(); });
  var offsetX = offsets.left;
  var offsetY = offsets.top;
  return (offsetY >=0) && (offsetY + height <= document.viewport.getHeight());
}

ProtoCalendar.callWithVisibility = function(element, func) {
  element = $(element);
  var display = $(element).getStyle('display');
  if (display != 'none' && display != null) {// Safari bug 
    return func();
  }
  var els = element.style;
  var originalVisibility = els.visibility;
  var originalPosition = els.position;
  var originalDisplay = els.display;
  els.visibility = 'hidden';
  els.position = 'absolute';
  els.display = 'block';
  var result = func();
  els.display = originalDisplay;
  els.position = originalPosition;
  els.visibility = originalVisibility;
  return result;
}

Object.extend(ProtoCalendar, {
                JAN: 0,
                FEB: 1,
                MAR: 2,
                APR: 3,
                MAY: 4,
                JUNE: 5,
                JULY: 6,
                AUG: 7,
                SEPT: 8,
                OCT: 9,
                NOV: 10,
                DEC: 11,

                SUNDAY: 0,
                MONDAY: 1,
                TUESDAY: 2,
                WEDNESDAY: 3,
                THURSDAY: 4,
                FRIDAY: 5,
                SATURDAY: 6,

                getNumDayOfMonth: function(year, month){
                  return 32 - new Date(year, month, 32).getDate();
                },

                getDayOfWeek: function(year, month, day) {
                  return new Date(year, month, day).getDay();
                }
              });

ProtoCalendar.prototype = {
  initialize: function(options) {
    var date = ProtoCalendar.newDate();
    this.options = Object.extend({
                                   month: date.getMonth(),
                                   year: date.getFullYear(),
                                   lang: ProtoCalendar.LangFile.defaultLang
                                 }, options || { });
    var getHolidays = ProtoCalendar.LangFile[this.options.lang]['getHolidays'];
    if (getHolidays) {
      this.initializeHolidays = getHolidays.bind(top, this);
    } else {
      this.initializeHolidays = function() { this.holidays = []; };
    }
    this.date = new Date(this.options.year, this.options.month, 1);
  },

  getMonth: function() {
    return this.date.getMonth();
  },

  getYear: function() {
    return this.date.getFullYear();
  },

  invalidate: function() {
    this.holidays = undefined;
  },

  setMonth: function(month) {
    if (month != this.getMonth()) {
      this.invalidate();
    }
    return this.date.setMonth(month);
  },

  setYear: function(year) {
    if (year != this.getYear()) {
      this.invalidate();
    }
    return this.date.setFullYear(year);
  },

  getDate: function() {
    return this.date;
  },

  setDate: function(date) {
    this.invalidate();
    this.date = date;
  },

  setYearByOffset: function(offset) {
    if (offset != 0) {
      this.invalidate();
    }
    this.date.setFullYear(this.date.getFullYear() + offset);
  },

  setMonthByOffset: function(offset) {
    if (offset != 0) {
      this.invalidate();
    }
    this.date.setMonth(this.date.getMonth() + offset);
  },

  getNumDayOfMonth: function() {
    return ProtoCalendar.getNumDayOfMonth(this.getYear(), this.getMonth());
  },

  getDayOfWeek: function(day) {
    return ProtoCalendar.getDayOfWeek(this.getYear(), this.getMonth(), day);
  },

  clone: function() {
    return new ProtoCalendar({year: this.getYear(), month: this.getMonth()});
  },

  getHoliday: function(day) {
    if(!this.holidays) { this.initializeHolidays();}
    var holiday = this.holidays[day];
    return holiday? holiday : false;
  },

  initializeHolidays: function() {
  }
};

var AbstractProtoCalendarRender = Class.create();
Object.extend(AbstractProtoCalendarRender, {
                id: 1,
                WEEK_DAYS_SUNDAY: [ 0, 1, 2, 3, 4, 5, 6 ],
                WEEK_DAYS_MONDAY: [ 1, 2, 3, 4, 5, 6, 0 ],
                WEEK_DAYS_INDEX_SUNDAY: [ 0, 1, 2, 3, 4, 5, 6 ],
                WEEK_DAYS_INDEX_MONDAY: [ 6, 0, 1, 2, 3, 4, 5 ],

                getId: function() {
                  var id = AbstractProtoCalendarRender.id;
                  AbstractProtoCalendarRender.id += 1;
                  return id;
                }
               });

AbstractProtoCalendarRender.prototype = {
  initialize: function(options) {
    this.id = AbstractProtoCalendarRender.getId();
    this.options = Object.extend({
                                   weekFirstDay : ProtoCalendar.MONDAY,
                                   containerClass: 'cal-container',
                                   tableClass: 'cal-table',
                                   headerTopClass: 'cal-header-top',
                                   headerClass: 'cal-header',
                                   headerBottomClass: 'cal-header-bottom',
                                   bodyTopClass: 'cal-body-top',
                                   bodyClass: 'cal-body',
                                   bodyBottomClass: 'cal-body-bottom',
                                   bodyId: this.getIdPrefix() + '-body',
                                   footerTopClass: 'cal-footer-top',
                                   footerClass: 'cal-footer',
                                   footerBottomClass: 'cal-footer-bottom',
                                   footerId: this.getIdPrefix() + '-footer',
                                   yearSelectClass: 'cal-select-year',
                                   yearSelectId: this.getIdPrefix() + '-select-year',
                                   monthSelectClass: 'cal-select-month',
                                   monthSelectId: this.getIdPrefix() + '-select-month',
                                   borderClass: 'cal-border',
                                   hourMinuteInputClass: 'cal-input-hour-minute',
                                   hourMinuteInputId: this.getIdPrefix() + '-input-hour-minute',
                                   hourInputClass: 'cal-input-hour',
                                   hourInputId: this.getIdPrefix() + '-input-hour',
                                   minuteInputClass: 'cal-input-minute',
                                   minuteInputId: this.getIdPrefix() + '-input-minute',
                                   secondInputClass: 'cal-input-second',
                                   secondInputId: this.getIdPrefix() + '-input-second',
                                   okButtonClass: 'cal-ok-button',
                                   okButtonId: this.getIdPrefix() + '-ok-button',
                                   errorDivClass: 'cal-error-list',
                                   errorDivId: this.getIdPrefix() + '-error-list',
                                   labelRowClass: 'cal-label-row',
                                   labelCellClass: 'cal-label-cell',
                                   nextButtonClass: 'cal-next-btn',
                                   prevButtonClass: 'cal-prev-btn',
                                   dayCellClass: 'cal-day-cell',
                                   dayClass: 'cal-day',
                                   weekdayClass: 'cal-weekday',
                                   sundayClass: 'cal-sunday',
                                   saturdayClass: 'cal-saturday',
                                   holidayClass: 'cal-holiday',
                                   otherdayClass: 'cal-otherday',
                                   disabledDayClass: 'cal-disabled',
                                   selectedDayClass: 'cal-selected',
                                   nextBtnId: this.getIdPrefix() + '-next-btn',
                                   prevBtnId: this.getIdPrefix() + '-prev-btn',
                                   lang: ProtoCalendar.LangFile.defaultLang,
                                   showEffect: 'Appear',
                                   hideEffect: 'Fade',
                                   ifInvisible: 'Flip', /* None | Scroll | Flip */
                                   scrollMargin: 20
                                 }, options || {});
    this.langFile = ProtoCalendar.LangFile[this.options.lang];
    this.weekFirstDay = this.options.weekFirstDay;
    this.initWeekData();
    this.container = this.createContainer();
    this.alignTo = $(this.options.alignTo);
    this.alignOrient = 'Below';
    if (navigator.appVersion.match(/\bMSIE\b/)) {
      this.iframe = this.createIframe();
    }
    this.resizeHandler = this.setPosition.bind(this);
  },

  createContainer: function() {
    var container = $(document.createElement('div'));
    container.addClassName(this.options.containerClass);
    container.setStyle({position:'absolute',
                        top: "0px",
                        left: "0px",
                        zindex:1,
                        display: 'none'});
    container.hide();
    document.body.appendChild(container);
    return container;
  },

  createIframe: function() {
    var iframe = document.createElement("iframe");
    iframe.setAttribute("src", "javascript:false;");
    iframe.setAttribute("frameBorder", "0");
    iframe.setAttribute("scrolling", "no");
    Element.setStyle(iframe, { position:'absolute',
                               top: "0px",
                               left: "0px",
                               zindex:10,
                               display: 'none',
                               overflow: 'hidden',
                               filter: 'progid:DXImageTransform.Microsoft.Alpha(opacity=0)'
                             });
    document.body.appendChild(iframe);
    return $(iframe);
  },

  getWeekdayLabel: function(weekday) {
    return this.langFile.WEEKDAY_ABBRS[weekday];
  },

  getWeekdays: function() {
    return this.weekdays;
  },

  initWeekData: function() {
    if (this.weekFirstDay == ProtoCalendar.SUNDAY) {
      this.weekLastDay = ProtoCalendar.SATURDAY;
      this.weekdays = AbstractProtoCalendarRender.WEEK_DAYS_SUNDAY;
      this.weekdaysIndex = AbstractProtoCalendarRender.WEEK_DAYS_INDEX_SUNDAY;
    } else {
      this.weekFirstDay == ProtoCalendar.MONDAY
      this.weekLastDay = ProtoCalendar.SUNDAY;
      this.weekdays = AbstractProtoCalendarRender.WEEK_DAYS_MONDAY;
      this.weekdaysIndex = AbstractProtoCalendarRender.WEEK_DAYS_INDEX_MONDAY;
    }
  },

  getCalendarBeginDay: function(calendar) {
    var offset = this.getDayIndexOfWeek(calendar, 1);
    var date = new Date(calendar.getYear(), calendar.getMonth(), 1 - offset);
    return date;
  },

  getCalendarEndDay: function(calendar) {
    var lastDayOfMonth = calendar.getNumDayOfMonth();
    var offset = 6 - this.getDayIndexOfWeek(calendar, lastDayOfMonth);
    var date = new Date(calendar.getYear(), calendar.getMonth(), lastDayOfMonth + offset + 1);
    return date;
  },

  getDayIndexOfWeek: function(calendar, day) {
    return this.weekdaysIndex[ calendar.getDayOfWeek(day) ];
  },

  getIdPrefix: function() {
    return 'cal' + this.id;
  },

  getDayDivId: function(date) {
    return this.getIdPrefix() + '-year' + date.getFullYear() + '-month' + date.getMonth() + '-day' + date.getDate();
  },

  setPosition: function() {
    if (!this.alignTo) return true;
    this.setAlignment(this.alignTo, this.container, this.alignOrient);
    var withinView = ProtoCalendar.withinViewport(this.container);
    if (!withinView && this.options.ifInvisible == 'Flip') {
      this.alignOrient = (this.alignOrient == 'Above' ? 'Below' : 'Above');
      this.setAlignment(this.alignTo, this.container, this.alignOrient);
    }
    if (this.iframe) {
      var dimensions = Element.getDimensions(this.container);
      this.iframe.setAttribute("width", dimensions.width);
      this.iframe.setAttribute("height", dimensions.height);
      this.setAlignment(this.alignTo, this.iframe, this.alignOrient);
    }
    if (this.options.ifInvisible == 'Scroll') this.scrollIfInvisible();
    return true;
  },

  setAlignment: function(alignTo, element, pos) {
    var offsets = Position.cumulativeOffset(alignTo);
    element.setStyle({left: offsets[0] + "px"});
    if (pos == 'Above') {
      var elementHeight = ProtoCalendar.callWithVisibility(element, function() { return element.offsetHeight; });
      element.setStyle({top: (offsets[1] - elementHeight) + "px"});
    } else if (pos == 'Below') {
      element.setStyle({top: (offsets[1] + alignTo.offsetHeight) + "px"});
    } else {
      //Unknown option
    }
  },

  show: function(option) {
    Event.observe(window, 'resize', this.resizeHandler);
    this.setPosition();
    if (typeof Effect != 'undefined') {
      var effect =  this.options['showEffect'] || 'Appear';
      if (!this._effect || this._effect.state == 'finished') {
        this._effect = new Effect[effect](this.container, {duration: 0.5});
      }
    } else {
      this.container.show();
    }
    if (this.iframe) this.iframe.show();
  },

  scrollIfInvisible: function() {
    var container = this.container;
    var dimensions = ProtoCalendar.callWithVisibility(container, function() { return container.getDimensions(); });
    var width = dimensions.width;
    var height = dimensions.height;
    var offsets = ProtoCalendar.callWithVisibility(container, function() { return container.viewportOffset(); });
    var offsetX = offsets.left;
    var offsetY = offsets.top;
    var diff = offsetY + height - document.viewport.getHeight();
    if (diff > 0) {
      window.scrollBy(0, diff + this.options.scrollMargin);
    }
  },    

  hide: function(option) {
    Event.stopObserving(window, 'resize', this.resizeHandler);
    if (!this.container.visible()) {
      return ;
    }
    if (typeof Effect != 'undefined') {
      var effect =  this.options['hideEffect'] || 'Fade';
      if (!this._effect || this._effect.state == 'finished') {
        this._effect = new Effect[effect](this.container, {duration: 0.3});
      }
    } else {
      this.container.hide();
    }
    if (this.iframe) this.iframe.hide();
  },

  hideImmediately: function(option) {
    if (!this.container.visible()) {
      return ;
    }
    this.container.hide();
    if (this.iframe) this.iframe.hide();
  },

  toggle: function(element) {
    this.container.visible() ? this.hide() : this.show();
  },

  render: function(calendar) { },

  rerender: function(calendar) { },

  getContainer: function() {
    return this.container;
  },

  getPrevButton: function() {
    return $(this.options.prevBtnId);
  },

  getNextButton: function() {
    return $(this.options.nextBtnId);
  },

  getYearSelect: function() {
    return $(this.options.yearSelectId);
  },

  getMonthSelect: function() {
    return $(this.options.monthSelectId);
  },

  getHourInput: function() {
    return $(this.options.hourInputId);
  },

  getMinuteInput: function() {
    return $(this.options.minuteInputId);
  },

  getSecondInput: function() {
    return $(this.options.secondInputId);
  },

  getOkButton: function() {
    return $(this.options.okButtonId);
  },

  getBody: function() {
    return $(this.options.bodyId);
  },

  getDayDivs: function() {
    //Good Performance for IE
    var divEls = [];
    var dayDivs = this.dayDivs;
    for (var i = 0; i < dayDivs.length; i++) {
      divEls.push(document.getElementById(dayDivs[i]));
    }
    return divEls;
    //return this.container.getElementsBySelector("a." + this.options.dayClass);
  },

  getDateFromEl: function(el) {
    var element = $(el);
    return new Date(element.readAttribute('year'), element.readAttribute('month'), element.readAttribute('day'));
  },

  //Set hour minute (second) to date from the input, if invalid return undefined.
  //The input date parameter will not be tainted even if it fails, because the return result is a copy.
  injectHourMinute: function(date) {
    if (!date || isNaN(date.getTime())) return undefined;
    var rd = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    rd.setHours(parseInt(this.getHourInput().value, 10));
    rd.setMinutes(this.getMinuteInput().value);
    if (this.options.enableSecond) rd.setSeconds(this.getSecondInput().value);
    return isNaN(rd.getTime()) ? undefined : rd;
  },

  selectDate: function(date) {
    var dayEl = $(this.getDayDivId(date));
    if (dayEl) dayEl.addClassName(this.options.selectedDayClass);
  },

  selectTime: function(date) {
    if (!date) return;
    this.getHourInput().value = date.getHours();
    this.getMinuteInput().value = date.getMinutes();
    if (this.options.enableSecond) this.getSecondInput().value = date.getSeconds();
  },

  deselectDate: function(date) {
    if (date) {
      var dateEl = $(this.getDayDivId(date));
      if (dateEl) dateEl.removeClassName(this.options.selectedDayClass);
    }
  },

  evaluateWithOptions: function(html) {
    var template = new Template(html);
    return template.evaluate(this.options);
  },

  defaultOnError: function(msg) {
    this.ensureErrorDiv();
    this.errorDiv.show();
    this.errorDiv.innerHTML += '<li>' + this.langFile[msg] + '</li>';
  },

  hideError: function() {
    this.ensureErrorDiv();
    this.errorDiv.innerHTML = '';
    this.errorDiv.hide();
  },

  ensureErrorDiv: function() {
    if (!this.errorDiv) {
      var errorDivHtml = '<div class="#{errorDivClass}" id="#{errorDivId}"><ul></ul></div>';
      new Insertion.Before($(this.options.footerId), this.evaluateWithOptions(errorDivHtml));
      this.errorDiv = $(this.options.errorDivId);
    }
    },

  isSelectable: function(date) {
      return (this.options.minDate - date) <= 0 && (date - this.options.maxDate) <= 0;
    }
  
};

var ProtoCalendarRender = Class.create();
Object.extend(ProtoCalendarRender.prototype, AbstractProtoCalendarRender.prototype);

Object.extend(
  ProtoCalendarRender.prototype,
  {
    render: function(calendar) {
      var html = '';
      html += this.renderHeader(calendar);
      html += '<div class="#{bodyTopClass}"></div><div class="#{bodyClass}" id="#{bodyId}">';
      html += '</div><div class="#{bodyBottomClass}"></div>';
      if (this.options.enableHourMinute) html += this.renderHourMinute();
      html += this.renderFooter(calendar);
      this.container.innerHTML = this.evaluateWithOptions(html);
      this.rerender(calendar);
    },

    rerender: function(calendar) {
      this.getBody().innerHTML = this.evaluateWithOptions(this.renderBody(calendar));
      SelectCalendar.selectOption(this.getMonthSelect(), calendar.getMonth());
      SelectCalendar.selectOption(this.getYearSelect(), calendar.getYear());
      if (this.container.visible()) this.setPosition();
    },

    renderHeader: function(calendar) {
      var html = '';
      // required 'href'
      html += '<div class="#{headerTopClass}"></div><div class="#{headerClass}">' +
        '<a href="#" id="#{prevBtnId}" class="#{prevButtonClass}">&lt;&lt;</a>' +
        this.createSelect(calendar.getYear(), calendar.getMonth()) +
        '<a href="#" id="#{nextBtnId}" class="#{nextButtonClass}">&gt;&gt;</a>' +
        '</div><div class="#{headerBottomClass}"></div>';
      return html;
    },

    renderFooter: function(calendar) {
      return '<div class="#{footerTopClass}"></div><div class="#{footerClass}" id="#{footerId}"></div><div class="#{footerBottomClass}"></div>';
    },

    renderHourMinute: function() {
      if (!this.hourMinuteHtml) {
        var html = '<div class="#{borderClass}"></div><div id="#{hourMinuteInputId}" class="#{hourMinuteInputClass}">';
        html += '<input type="text" name="hour" size="2" maxlength="2" class="#{hourInputClass}" id="#{hourInputId}" />' +
          ':<input type="text" name="minute" size="2" maxlength="2" class="#{minuteInputClass}" id="#{minuteInputId}" />';
        if (this.options.enableSecond) {
          html += ':<input type="text" name="second" size="2" maxlength="2" class="#{secondInputClass}" id="#{secondInputId}"/>';
        }
        html += '<input type="button" value="' + this.langFile['OK_LABEL'] + '" class="#{okButtonClass}" name="ok_button" id="#{okButtonId}"/>';
        html += '</div>';
        this.hourMinuteHtml =  html;
      }
      return this.hourMinuteHtml;
    },

    createSelect: function(year, month) {
      var yearPart = this.createYearSelect(year) + this.langFile.YEAR_LABEL;
      var monthPart = this.createMonthSelect(month) + this.langFile.MONTH_LABEL;
      if (this.langFile.YEAR_AND_MONTH) {
        return  yearPart + monthPart;
      } else {
        return monthPart + yearPart;
      }
    },

    createYearSelect: function(year) {
      var html = '';
      html += '<select id="#{yearSelectId}" class="#{yearSelectClass}">';
      for (var y = this.options.startYear, endy = this.options.endYear; y <= endy; y += 1) {
        html += '<option value="' + y + '"' + (y == year ? ' selected' : '') + '>' + y + '</option>';
      }
      html += '</select>';
      return html;
    },

    createMonthSelect: function(month) {
      if (!this.monthSelectHtml) {
        var html = '';
        html += '<select id="#{monthSelectId}" class="#{monthSelectClass}">';
        for (var m = ProtoCalendar.JAN; m <= ProtoCalendar.DEC; m += 1) {
          html += '<option value="' + m + '"' + (m == month ? ' selected' : '') + '>' + this.langFile['MONTH_ABBRS'][m] + '</option>';
        }
        html += '</select>';
        this.monthSelectHtml = html;
      }
      return this.monthSelectHtml;
    },

    renderBody: function(calendar) {
      this.dayDivs = [];
      var html = '<table class="#{tableClass}" cellspacing="0">';
      html += '<tr class="#{labelRowClass}">';
      var othis = this;
      if (!this.headHtml) {
        this.headHtml = '';
        $A(this.getWeekdays()).each(function(weekday) {
                                      var exClassName = '';
                                      if (weekday == ProtoCalendar.SUNDAY) { exClassName = ' #{sundayClass}'; }
                                      if (weekday == ProtoCalendar.SATURDAY) { exClassName = ' #{saturdayClass}'; }
                                      othis.headHtml += '<th class="#{labelCellClass}' + exClassName + '">' +
                                        othis.getWeekdayLabel(weekday) +
                                        '</th>';
                                    });
      }
      html += this.headHtml;
      var curDay = this.getCalendarBeginDay(calendar);
      var calEndDay = this.getCalendarEndDay(calendar);
      html += '<tbody>';
      var dayNum = Math.round((calEndDay - curDay) / 1000 / 60 / 60 / 24);
      for(var i = 0; i < dayNum; i += 1, curDay.setDate(curDay.getDate() + 1)) {
        var divClassName;
        var holiday = calendar.getHoliday(curDay.getDate());
        if(curDay.getMonth() != calendar.getMonth()) {
          divClassName = this.options.otherdayClass;
        } else if (holiday) {
          divClassName = this.options.holidayClass;
        } else if (curDay.getDay() == ProtoCalendar.SUNDAY) {
          divClassName = this.options.sundayClass;
        } else if (curDay.getDay() == ProtoCalendar.SATURDAY) {
          divClassName = this.options.saturdayClass;
        } else {
          divClassName = this.options.weekdayClass;
        }

        if (curDay.getDay() == this.weekFirstDay) { html += '<tr>'; }
        var dayId = this.getDayDivId(curDay);
        var dayHtml = '';
        if (this.isSelectable(curDay)) {
          dayHtml = '<a class="#{dayClass}" href="#" id="' + dayId +
            (holiday ? '" title="' + holiday : '') +
            '" year="' + curDay.getFullYear() +
            '" month="' + curDay.getMonth() +
            '" day="' + curDay.getDate() +
            '">' + curDay.getDate() + '</a>';
          this.dayDivs.push(dayId);
        } else {
          divClassName += ' ' + this.options.disabledDayClass;
          dayHtml = curDay.getDate();
        }
        html += '<td class="' + divClassName + ' #{dayCellClass}">' + dayHtml + '</td>';
        if (curDay.getDay() == this.weekLastDay) { html += '</tr>'; }
      }
      html += '</tbody></table>';
      return html;
    }

  });

var ProtoCalendarController = Class.create();
ProtoCalendarController.prototype = {
  initialize: function(calendarRender, options) {
    this.options = Object.extend({
                                   onHourMinuteError: this.defaultOnHourMinuteError.bind(this),
                                   onNoDateError: this.defaultOnNoDateError.bind(this)
                                 }, options);
    this.calendarRender = calendarRender;
    this.initializeDate();
    this.calendar = new ProtoCalendar(this.options);
    this.calendarRender.render(this.calendar);
    if (options.year && options.month && options.day) {
      var date = new Date(this.options.year, this.options.month, this.options.day);
      if (options.hour && options.minute && options.second) {
        date.setHours(options.hour, options.minute && options.second);
      }
      this.selectDate(date, true);
    } else {
      this.selectDate(null);
    }
    this.observeEventsOnce();
    this.observeEvents();
    this.onChangeHandlers = [];
  },

  initializeDate: function() {
    var date = ProtoCalendar.newDate();
    if (!this.options.year) {
      if (date.getFullYear() >= this.options.startYear && date.getFullYear() <= this.options.endYear) { 
        this.options.year = date.getFullYear();
      } else {
        this.options.year = this.options.startYear;
      }
    }
    if (!this.options.month) {
      this.options.month = date.getMonth();
    }
    if (!this.options.day) {
      this.options.day = date.getDate();
    }
  },

  observeEventsOnce: function() {
    var calrndr = this.calendarRender;
    calrndr.getPrevButton().observe('click', this.showPrevMonth.bindAsEventListener(this));
    calrndr.getNextButton().observe('click', this.showNextMonth.bindAsEventListener(this));
    var othis = this;
    var yearSelect = calrndr.getYearSelect();
    var monthSelect = calrndr.getMonthSelect();
    var year = this.calendar.getYear();
    var month = this.calendar.getMonth();
    yearSelect.observe('change', function() {
                         othis.setMonth(parseInt(yearSelect[yearSelect.selectedIndex].value, 10), parseInt(monthSelect[monthSelect.selectedIndex].value, 10));
                       });
    monthSelect.observe('change', function() {
                          othis.setMonth(parseInt(yearSelect[yearSelect.selectedIndex].value, 10), parseInt(monthSelect[monthSelect.selectedIndex].value, 10));
                       });
    // add auto focus
    if (this.options.enableHourMinute) {
      var hour = calrndr.getHourInput();
      var minute = calrndr.getMinuteInput();
      hour.observe('keyup', this._autoFocus.bindAsEventListener(hour, minute));
      hour.observe('keydown', this._disablePaste.bindAsEventListener(hour));
      hour.observe('contextmenu', this._disableContextMenu.bindAsEventListener(hour));
      var nextEl = this.options.enableSecond ? calrndr.getSecondInput() : calrndr.getOkButton();
      minute.observe('keyup', this._autoFocus.bindAsEventListener(minute, nextEl));
      minute.observe('keydown', this._disablePaste.bindAsEventListener(minute));
      minute.observe('contextmenu', this._disableContextMenu.bindAsEventListener(minute));
      if (navigator.appVersion.match(/\bMSIE\b/)) {
        hour.setStyle({'imeMode': 'disabled'});
        minute.setStyle({'imeMode': 'disabled'});
      }
    }
    if (this.options.enableSecond) {
      var second = calrndr.getSecondInput();
      second.observe('keyup', this._autoFocus.bindAsEventListener(second, calrndr.getOkButton()));
      second.observe('keydown', this._disablePaste.bindAsEventListener(second));
      second.observe('contextmenu', this._disableContextMenu.bindAsEventListener(second));
      if (navigator.appVersion.match(/\bMSIE\b/)) {
        second.setStyle({'imeMode': 'disabled'});
      }
    }
    if (this.options.enableHourMinute) calrndr.getOkButton().observe('click', this.onSubmit.bind(this));
  },
  _disableContextMenu: function(event) {
    Event.stop(event);
    return false;
  },
  _disablePaste: function(event) {
    // ctrl + v || shift + insert
    if ((event.keyCode == 86 && event.ctrlKey) || (event.keyCode == 45 && event.shiftKey)) {
      Event.stop(event);
      return false;
    }
  },
  _autoFocus: function(event, nextEl) {
    // shift || tab
    if (event.keyCode == 16 || event.keyCode == 9 || (event.keyCode == 9 && event.shiftKey)) {
      Event.stop(event);
      return false;
    }
    var v = this.value;
    if (v.length && v.length == 2) {
      nextEl.focus();
      nextEl.select();
    }
    return true;
  },
  observeEvents: function() {
    var othis = this;
    this.calendarRender.getDayDivs().each(function(el) {
                                            Event.observe(el, 'click', othis.onClickHandler.bindAsEventListener(othis));
                                          });
  },

  onClickHandler: function(event) {
    Event.stop(event);
    var date = this.calendarRender.getDateFromEl(Event.element(event));
    if (date) {
      this.selectDate(date);
      if (!this.options.enableHourMinute) {
        this.onChangeHandler();
        setTimeout(this.hideCalendar.bind(this), 150);
      }
    }
  },

  onSubmit: function() {
    this.hideError();
    var date = this.selectedDate;
    if (!date) return this.options.onNoDateError();
    date = this.calendarRender.injectHourMinute(date);
    if (!date) {
      this.options.onHourMinuteError();
    } else {
      this.selectDate(date, true);
      if (this.options.enableHourMinute) this.calendarRender.selectTime(date);
      this.onChangeHandler();
      this.hideCalendar();
    }
  },

  selectDate: function(date, redraw) {
    this.calendarRender.deselectDate(this.selectedDate);
    this.selectedDate = date;
    if (!date) return;
    if (redraw && (date.getFullYear() != this.calendar.getYear() || date.getMonth() != this.calendar.getMonth())) {
      this.setMonth(date.getFullYear(), date.getMonth());
    }
    this.calendarRender.selectDate(this.selectedDate);
  },

  getSelectedDate: function() {
    return this.selectedDate;
  },

  addChangeHandler: function(func) {
    this.onChangeHandlers.push(func);
  },

  onChangeHandler: function() {
    this.onChangeHandlers.each(function(f) { f(); });
  },

  showCalendar: function() {
    this.calendarRender.show();
  },

  hideCalendar: function() {
    this.calendarRender.hide();
  },

  blurCalendar: function(event) {
    if (event.keyCode == 9) {
      this.hideImmediatelyCalendar();
    }
  },

  hideImmediatelyCalendar: function() {
    this.calendarRender.hideImmediately();
  },

  toggleCalendar: function() {
    this.calendarRender.toggle();
  },

  showPrevMonth: function(event) {
    this.shiftMonthByOffset(-1);
    if (event) Event.stop(event);
  },

  showNextMonth: function(event) {
    this.shiftMonthByOffset(1);
    if (event) Event.stop(event);
  },

  shiftMonthByOffset: function(offset) {
    if (offset == 0) return;
    var newDate = new Date(this.calendar.getDate().getTime());
    newDate.setMonth(newDate.getMonth() + offset);
    if (this.options.startYear > newDate.getFullYear() || this.options.endYear < newDate.getFullYear()) return;
    this.calendar.setMonthByOffset(offset);
    this.afterSet();
  },

  setMonth: function(year, month) {
    if (this.calendar.getYear() == year && this.calendar.getMonth() == month) return;
    this.calendar.setYear(year);
    this.calendar.setMonth(month);
    this.afterSet();
  },

  afterSet: function() {
    this.calendarRender.rerender(this.calendar);
    this.selectDate(this.selectedDate);
    this.observeEvents();
  },

  getContainer: function() {
    return this.calendarRender.getContainer();
  },

  defaultOnHourMinuteError: function() {
    this.calendarRender.defaultOnError('HOUR_MINUTE_ERROR');
  },

  defaultOnNoDateError: function() {
    this.calendarRender.defaultOnError('NO_DATE_ERROR');
  },

  hideError: function() {
    this.calendarRender.hideError();
  }
};

//Don't instantiate this, extend BaseCalendar
var BaseCalendar = Class.create();
BaseCalendar.bindOnLoad = function(f) {
  if (document.observe) {
    document.observe('dom:loaded', f);
  } else {
    Event.observe(window, 'load', f);
  }
};


BaseCalendar.prototype = {
  initialize: function(options) {
    throw "Cannot instantiate BaseCalendar.";
  },

  initializeOptions: function(options) {
    if (!options) options = {};
    this.options = Object.extend({
                                   startYear: ProtoCalendar.newDate().getFullYear() - 10,
                                   endYear: ProtoCalendar.newDate().getFullYear() + 10,
                                   minDate: new Date(1900, 0, 1),
                                   maxDate: new Date(3000, 0, 1),
                                   format: ProtoCalendar.LangFile[options.lang || ProtoCalendar.LangFile.defaultLang]['DEFAULT_FORMAT'],
                                   enableHourMinute: false,
                                   enableSecond: false,
                                   lang: ProtoCalendar.LangFile.defaultLang,
                                   triggers: []
                                 }, options);
  },

  initializeBase: function() {
    this.calendarController = new ProtoCalendarController(new ProtoCalendarRender(this.options), this.options);
    this.langFile = ProtoCalendar.LangFile[this.options.lang] || ProtoCalendar.LangFile.defaultLangFile();
    this.triggers = [];
    this.options.triggers.each(this.addTrigger.bind(this));
    this.changeHandlers = [];
    this.observeEvents();
  },

  addTrigger: function(el) {
    this.triggers.push($(el));
    $(el).setStyle({'cursor': 'pointer'});
  },

  observeEvents: function() {
    Event.observe(document.body, 'click', this.windowClickHandler.bindAsEventListener(this));
    this.calendarController.addChangeHandler(this.onCalendarChange.bind(this));
    this.doObserveEvents();
  },

  doObserveEvents: function() {
    //Override this
  },

  windowClickHandler: function(event) {
    var target = $(Event.element(event));
    if (this.triggers.include(target)) {
      this.calendarController.toggleCalendar();
    } else if (target != this.input && !Element.descendantOf(target, this.calendarController.getContainer())) {
      this.calendarController.hideCalendar();
    }
  },

  addChangeHandler: function(f) {
    this.changeHandlers.push(f);
  },

  onCalendarChange: function() {
    this.changeHandlers.each(function(f) { f(); });
  }
};

var InputCalendar = Class.create();
InputCalendar.createOnLoaded = function(input, options) {
  BaseCalendar.bindOnLoad(function() {
    new InputCalendar(input, options);
  });
};
InputCalendar.initCalendars = function(inputs, options) {
  if (document.observe) {
    document.observe('dom:loaded', function() {
      $$(inputs).each(function(input) {
        new InputCalendar(input, options);
      });
    });
  } else {
    Event.observe(window, 'load', function() {
      $$(inputs).each(function(input) {
        new InputCalendar(input, options);
      });
    });
  }
};
Object.extend(InputCalendar.prototype, BaseCalendar.prototype);
Object.extend(
  InputCalendar.prototype,
  {
    initialize: function(input, options) {
      this.input = $(input); // used in doObserveEvents()
      this.initializeOptions(options);
      this.options = Object.extend({
                                     alignTo: input,
                                     inputReadOnly: false,
                                     labelFormat: undefined,
                                     labelEl: undefined
                                   }, this.options);
      this.initializeBase();
      this.initializeInput();
      this.initializeLabel();
    },

    initializeInput: function() {
      this.dateFormat = new ProtoCalendar.DateFormat(this.options.format);
      if (this.input.value && this.dateFormat.parse(this.input.value)) {
        this.onInputChange();
      } else {
        this.onCalendarChange();
      }
      if (this.options.enableHourMinute) {
        this.calendarController.calendarRender.selectTime(this.calendarController.selectedDate);
      }
      if (this.options.inputReadOnly) {
        this.input.setAttribute('readOnly', this.options.inputReadOnly);
      }
    },

    initializeLabel: function() {
      this.labelFormat = new ProtoCalendar.DateFormat(this.options.labelFormat || this.langFile['LABEL_FORMAT']);
      var labelElm = $(this.options.labelEl);
      if ((! labelElm) && this.options.labelFormat) {
        var labelId = this.input.id + '_label';
        new Insertion.After(this.input, "<div id='" + labelId + "'></div>");
        labelElm = $(labelId);
      }
      this.labelEl = labelElm;
      this.changeLabel();
    },

    changeLabel: function() {
      if (!this.labelEl) return;
      if (this.calendarController.getSelectedDate()) {
        this.labelEl.innerHTML = this.labelFormat.format(this.calendarController.getSelectedDate(), this.options.lang);
      }
    },

    doObserveEvents: function() {
      this.input.observe('change', this.onInputChange.bind(this));
      this.input.observe('focus', this.calendarController.showCalendar.bind(this.calendarController));
      this.input.observe('keydown', this.calendarController.blurCalendar.bindAsEventListener(this.calendarController));
      this.addChangeHandler(this.changeInputValue.bind(this));
      this.addChangeHandler(this.changeLabel.bind(this));
    },

    onInputChange: function() {
      var date = this.dateFormat.parse(this.input.value);
      if (date) {
        this.calendarController.selectDate(date, true);
        if (this.options.enableHourMinute) this.calendarController.calendarRender.selectTime(date);
      } else {
        var inputValue = this.input.value.toLowerCase();
        var date;
        if (this.langFile['today'] && this.langFile['today'] == inputValue || inputValue == 'today') {
          date = ProtoCalendar.newDate();
        } else if (this.langFile['tomorrow'] && this.langFile['tomorrow'] == inputValue || inputValue == 'tomorrow') {
          date = ProtoCalendar.newDate();
          date.setDate(date.getDate() + 1);
        } else if (this.langFile['yesterday'] && this.langFile['yesterday'] == inputValue || inputValue == 'yesterday') {
          date = ProtoCalendar.newDate();
          date.setDate(date.getDate() - 1);
        } else if (this.langFile.parseDate && (date = this.langFile.parseDate(inputValue))) {
          //done is parseDate
        } else {
          date = undefined;
        }
        this.calendarController.selectDate(date, true);
        this.onCalendarChange();
      }
      this.changeLabel();
    },

    changeInputValue: function() {
      this.input.value = this.dateFormat.format(this.calendarController.getSelectedDate(), this.options.lang);
    }
  });


ProtoCalendar.DateFormat = Class.create();
Object.extend(ProtoCalendar.DateFormat,
              {
                MONTH_ABBRS: ProtoCalendar.LangFile.en.MONTH_ABBRS,
                MONTH_NAMES: ProtoCalendar.LangFile.en.MONTH_NAMES,
                WEEKDAY_ABBRS: ProtoCalendar.LangFile.en.WEEKDAY_ABBRS,
                WEEKDAY_NAMES: ProtoCalendar.LangFile.en.WEEKDAY_NAMES,
                formatRegexp: /(?:d{3,4}i|d{1,4}|m{1,4}|yy(?:yy)?|([hHMs])\1?|TT|tt|[lL])|.+?/g,
                zeroize: function (value, length) {
                  if (!length) length = 2;
                  value = String(value);
                  for (var i = 0, zeros = ''; i < (length - value.length); i++) {
                    zeros += '0';
                  }
                  return zeros + value;
                }
              });

ProtoCalendar.DateFormat.prototype =  {
  initialize: function(format) {
    this.dateFormat = format;
    this.parserInited = false;
    this.formatterInited = false;
  },

  format: function(date, lang) {
    if (!this.formatterInited) this.initFormatter();
    if (!date) return '';
    var langFile = ProtoCalendar.LangFile[lang || ProtoCalendar.LangFile.defaultLang];
    var str = '';
    this.formatHandlers.each(function(f) {
                               str += f(date, langFile);
                             });
    return str;
  },

  initFormatter: function() {
    var handlers = [];
    var matches = this.dateFormat.match(ProtoCalendar.DateFormat.formatRegexp);
    for (var i = 0, n = matches.length; i < n; i++) {
      switch(matches[i]) {
      case 'd':       handlers.push(function(date, lf) { return date.getDate(); }); break;
      case 'dd':      handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getDate()) }); break;
      case 'ddd':     handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.WEEKDAY_ABBRS[date.getDay()]; }); break;
      case 'dddd':    handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.WEEKDAY_NAMES[date.getDay()]; }); break;
      case 'dddi':    handlers.push(function(date, lf) { return lf.WEEKDAY_ABBRS[date.getDay()]; }); break;
      case 'ddddi':   handlers.push(function(date, lf) { return lf.WEEKDAY_NAMES[date.getDay()]; }); break;
      case 'm':       handlers.push(function(date, lf) { return date.getMonth() + 1; }); break;
      case 'mm':      handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getMonth() + 1); }); break;
      case 'mmm':     handlers.push(function(date, lf) { return lf.MONTH_ABBRS[date.getMonth()]; }); break;
      case 'mmmm':    handlers.push(function(date, lf) { return (lf.MONTH_NAMES || ProtoCalendar.DateFormat)[date.getMonth()]; }); break;
      case 'yy':      handlers.push(function(date, lf) { return String(date.getFullYear()).substr(2); }); break;
      case 'yyyy':    handlers.push(function(date, lf) { return date.getFullYear(); }); break;
      case 'h':       handlers.push(function(date, lf) { return date.getHours() % 12 || 12; }); break;
      case 'hh':      handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getHours() % 12 || 12); }); break;
      case 'H':       handlers.push(function(date, lf) { return date.getHours(); }); break;
      case 'HH':      handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getHours()); }); break;
      case 'M':       handlers.push(function(date, lf) { return date.getMinutes(); }); break;
      case 'MM':      handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getMinutes()); }); break;
      case 's':       handlers.push(function(date, lf) { return date.getSeconds(); }); break;
      case 'ss':      handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getSeconds()); }); break;
      case 'l':       handlers.push(function(date, lf) { return ProtoCalendar.DateFormat.zeroize(date.getMilliseconds(), 3); }); break;
      case 'tt':      handlers.push(function(date, lf) { return date.getHours() < 12 ? 'am' : 'pm'; }); break;
      case 'TT':      handlers.push(function(date, lf) { return date.getHours() < 12 ? 'AM' : 'PM'; }); break;
      default:        handlers.push(ProtoCalendar.createIdentity(matches[i]));
      }
    };
    this.formatHandlers = handlers;
    this.formatterInited = true;
  },

  parse: function(str) {
    if (!this.parserInited) this.initParser();
    if (!str) return undefined;
    var results = str.match(this.parserRegexp);
    if (!results) return undefined;
    var date = ProtoCalendar.newDate();
    for (var i = 0, n = this.parseHandlers.length; i < n; i++) {
      if (this.parseHandlers[i] != undefined) {
        (this.parseHandlers[i])(date, results[i+1]);
      }
    }
    this.parseCallback(date);
    return date;
  },

  initParser: function() {
    var handlers = [];
    var regstr = '';
    var matches = this.dateFormat.match(ProtoCalendar.DateFormat.formatRegexp);
    var hour, ampm;

    for (var i = 0, n = matches.length; i < n; i++) {
      regstr += '(';
      switch(matches[i]) {
      case 'd':
      case 'dd':      regstr += '\\d{1,2}';
                      handlers.push(function(date, value) { date.setDate(value); });
                      break;
      case 'm':
      case 'mm':      regstr += '\\d{1,2}';
                      handlers.push(function(date, value) { 
                                      var m = parseInt(value, 10) - 1;
                                      date.setMonth(m); 
                                    });
                      break;
//       case 'mmm':     regstr += ProtoCalendar.DateFormat.MONTH_ABBRS.join('|');
//                       handlers.push(function(date, value) {
//                                       date.setMonth(ProtoCalendar.DateFormat.MONTH_ABBRS.indexOf(value)); });
//                       break;
//       case 'mmmm':    regstr += ProtoCalendar.DateFormat.MONTH_NAMES.join('|');
//                       handlers.push(function(date, value) {
//                                       date.setMonth(ProtoCalendar.DateFormat.MONTH_NAMES.indexOf(value)); });
//                       break;
      case 'yy':      regstr += '\\d{2}';
                      handlers.push(function(date, value) {
                                      var year = parseInt(value, 10);
                                      year = year < 70 ? 2000 + year : 1900 + year;
                                      date.setFullYear(year); });
                      break;
      case 'yyyy':    regstr += '\\d{4}';
                      handlers.push(function(date, value) { date.setFullYear(value); });
                      break;
      case 'h':
      case 'hh':      hour = true;
                      regstr += '\\d{1,2}';
                      handlers.push(function(date, value) {
                                      value = value % 12 || 0;
                                      date.setHours(value);
                                      });
                      break;
      case 'H':
      case 'HH':      regstr += '\\d{1,2}';
                      handlers.push(function(date, value) { date.setHours(value); });
                      break;
      case 'M':
      case 'MM':      regstr += '\\d{1,2}';
                      handlers.push(function(date, value) { date.setMinutes(value); });
                      break;
      case 's':
      case 'ss':      regstr += '\\d{1,2}';
                      handlers.push(function(date, value) { date.setSeconds(value); });
                      break;
      case 'l':       regstr += '\\d{1,3}';
                      handlers.push(function(date, value) { date.setMilliSeconds(value); });
                      break;
      case 'tt':      regstr += 'am|pm';
                      handlers.push(function(date, value) { ampm = value; });
                      break;
      case 'TT':      regstr += 'AM|PM';
                      handlers.push(function(date, value) { ampm = value.toLowerCase(); });
                      break;
      case 'mmm':
      case 'mmmm':
      case 'ddd':
      case 'dddd':
      case 'dddi':
      case 'ddddi':   regstr += '.+?';
                      handlers.push(undefined);
                      break;

      default:        regstr += matches[i];
                      handlers.push(undefined);
      }
      regstr += ')';
    }
    this.parserRegexp = new RegExp(regstr);
    this.parseHandlers = handlers;

    if (ampm == 'pm' && hour) {
      this.parseCallback = this.normalizeHour.bind(this);
    } else {
      this.parseCallback = function() {};
    }
    this.parserInited = true;
  },

  normalizeHour: function(date) {
    var hour = date.getHours();
    hour = hour == 12 ? 0 : hour + 12;
    date.setHours(hour);
  }
};

ProtoCalendar.createIdentity = function(v) {
  return function() { return v; }
}

var SelectCalendar = Class.create();
SelectCalendar.selectTimeOption = function(select, value) {
  var newValue = value - 0;
  newValue = newValue < 10 ? "0" + newValue : newValue;
  SelectCalendar.selectOption(select, newValue);
}

SelectCalendar.selectOption = function(select, value) {
  var selectEl = $(select);
  var options = selectEl.options;
  for (var i = 0; i < options.length; i++) {
    if (options[i].value === value.toString()) {
      options[i].selected = true;
      return;
    }
  }
}

SelectCalendar.createOnLoaded = function(select, options) {
  BaseCalendar.bindOnLoad(function() { new SelectCalendar(select, options); });
};
Object.extend(SelectCalendar.prototype, BaseCalendar.prototype);
Object.extend(
  SelectCalendar.prototype,
  {
    initialize: function(select, options) {
      this.yearSelect = $(select.yearSelect);
      this.monthSelect = $(select.monthSelect);
      this.daySelect = $(select.daySelect);
      this.initializeOptions(options);
      if (this.options.enableHourMinute) {
        this.hourSelect = $(select.hourSelect);
        this.minuteSelect = $(select.minuteSelect);
        if (this.options.enableSecond) {
          this.secondSelect = $(select.secondSelect);
        }
      }
      this.options = Object.extend({alignTo: select.yearSelect}, this.options);
      this.initializeBase();
      this.initializeSelect();
    },

    initializeSelect: function() {
      if (this.getSelectedDate()) {
        this.onSelectChange();
      } else {
        this.onCalendarChange();
      }
    },

    doObserveEvents: function() {
      this.yearSelect.observe('change', this.onSelectChange.bind(this));
      this.monthSelect.observe('change', this.onSelectChange.bind(this));
      this.daySelect.observe('change', this.onSelectChange.bind(this));
      if (this.options.enableHourMinute) {
        this.hourSelect.observe('change', this.onSelectChange.bind(this));
        this.minuteSelect.observe('change', this.onSelectChange.bind(this));
        if (this.options.enableSecond) {
          this.secondSelect.observe('change', this.onSelectChange.bind(this));
        }
      }
      this.addChangeHandler(this.changeSelectValue.bind(this));
    },

    onSelectChange: function() {
      var date = this.getSelectedDate();
      if (!date) return;
      this.calendarController.selectDate(date, true);
      if (this.options.enableHourMinute) {
        this.calendarController.calendarRender.selectTime(date);
      }
      this.onCalendarChange();
    },

    changeSelectValue: function() {
      var date = this.calendarController.getSelectedDate();
      if (date) {
        SelectCalendar.selectOption(this.yearSelect, date.getFullYear());
        SelectCalendar.selectOption(this.monthSelect, date.getMonth() + 1);
        SelectCalendar.selectOption(this.daySelect, date.getDate());
        if (this.options.enableHourMinute) {
          SelectCalendar.selectTimeOption(this.hourSelect, date.getHours());
          SelectCalendar.selectTimeOption(this.minuteSelect, date.getMinutes());
          if (this.options.enableSecond) {
            SelectCalendar.selectTimeOption(this.secondSelect, date.getSeconds());
          }
        }
      }
    },

    getSelectedDate: function() {
      if (this.yearSelect.value == '' 
          || this.monthSelect.value == '' 
          || this.daySelect.value == '') {
        return undefined;
      }
      var d = ProtoCalendar.newDate();
      d.setFullYear(this.yearSelect.value);
      d.setMonth(this.monthSelect.value - 1);
      d.setDate(this.daySelect.value);
      if (this.options.enableHourMinute) {
        if (this.hourSelect.value == '' || this.minuteSelect.value == '') {
          return undefined;
        }
        d.setHours(this.hourSelect.value - 0);
        d.setMinutes(this.minuteSelect.value - 0);
        if (this.options.enableSecond) {
          if (this.secondSelect.value == '') {
            return undefined;
          }
          d.setSeconds(this.secondSelect.value - 0);
        }
      }
      if (isNaN(d.getTime())) {
        return undefined;
      } else {
        return d;
      }
    }
  });

