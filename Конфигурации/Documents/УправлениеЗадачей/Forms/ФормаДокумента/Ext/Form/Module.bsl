﻿&НаКлиенте
Перем ПланированиеТРЗМодифицированность;


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УстановитьВидимость();
	ПланированиеТРЗМодифицированность = Ложь;
	
	Если Объект.ПроцентПодготовкиТЗ = 100 Тогда
		Элементы.ПроцентПодготовкиДО.ТолькоПросмотр = Ложь;
	Иначе
		Элементы.ПроцентПодготовкиДО.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	Если Объект.ПроцентПодготовкиДо = 100 Тогда
		Элементы.ПроцентВыполнения.ТолькоПросмотр = Ложь;
	Иначе
		Элементы.ПроцентВыполнения.ТолькоПросмотр = Истина;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте 
Процедура УстановитьВидимость()
	
	СтатусПриИзмененииНаСервере();
	ИнтеграцияПриИзмененииНаСервере();			  		   
КонецПроцедуры	

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	Если ПланированиеТРЗМодифицированность Тогда
		ДиалогСВопросом();
		Отказ = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДиалогСВопросом()
	
	ПланированиеТРЗМодифицированность = Ложь;
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтотОбъект);	
	ПоказатьВопрос(Оповещение, 
					"Были изменены данные табличной части Планирование ТРЗ. Выполнить перенос данных в регистр и обновление в документе?", 
					РежимДиалогаВопрос.ДаНет, 0, 
					КодВозвратаДиалога.Да, "");    
	
КонецПроцедуры
 
&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметры) Экспорт
 
	Если Результат = КодВозвратаДиалога.Да Тогда
		ЭтотОбъект.Записать();
		ПродолжитьЗапись = ПеренестиДанныеВРегистрПланированиеТРЗНаКлиенте();
		Если ПродолжитьЗапись Тогда
			ПланированиеТРЗМодифицированность = Ложь;
			ЭтотОбъект.Записать();
		КонецЕсли;
	Иначе 
		ПланированиеТРЗМодифицированность = Истина;
    КонецЕсли;	
 
КонецПроцедуры

&НаСервере
Процедура ОбновитьСтрокиНаСервере()
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПланированиеТРЗ.Период КАК Период,
		|	ПланированиеТРЗ.ТипЗадачи КАК ТипЗадачи,
		|	ПланированиеТРЗ.Заявка КАК Заявка,
		|	ПланированиеТРЗ.Исполнитель КАК Исполнитель,
		|	ПланированиеТРЗ.Часы КАК Часы,
		|	ПланированиеТРЗ.Статус КАК Статус,
		|	ПланированиеТРЗ.Комментарий КАК Комментарий
		|ИЗ
		|	РегистрСведений.ПланированиеТРЗ КАК ПланированиеТРЗ
		|ГДЕ
		|	ПланированиеТРЗ.СсылкаНаДокумент = &СсылкаНаДокумент
		|
		|УПОРЯДОЧИТЬ ПО
		|	Период";
	
	Запрос.УстановитьПараметр("СсылкаНаДокумент", Объект.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
			
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НоваяСтрока = Объект.ПланированиеТРЗ.Добавить();
		НоваяСтрока.Период = ВыборкаДетальныеЗаписи.Период;
		НоваяСтрока.Исполнитель = ВыборкаДетальныеЗаписи.Исполнитель;
		НоваяСтрока.Часы = ВыборкаДетальныеЗаписи.Часы;		
		НоваяСтрока.Статус = ВыборкаДетальныеЗаписи.Статус;
		НоваяСтрока.Комментарий = ВыборкаДетальныеЗаписи.Комментарий;

	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСтрокиНаКлиенте()
	Объект.ПланированиеТРЗ.Очистить();  
	ОбновитьСтрокиНаСервере();
	
	ИсполнительРанее = Неопределено;
	ПериодРанее = Дата("00010101000000");
	ЧасыМесяц = 0;
	Для каждого Строка Из Объект.ПланированиеТРЗ Цикл
		
		Исполнитель = Строка.Исполнитель;
		Период = Строка.Период;
		
		Часы = ПланированиеТРЗПериодПриИзмененииНаСервере(Строка.Период,Строка.Исполнитель);
         		Строка.ВсегоЗанятоЧасовВДень = Часы;
		
		Если НЕ (Исполнитель = ИсполнительРанее И НачалоМесяца(Период) = ПериодРанее) Тогда	
			ЧасыМесяц = ПроверкаТРЗМесяцНаСервере(Строка.Период, Строка.Исполнитель);			
			ИсполнительРанее = Исполнитель;
			ПериодРанее = НачалоМесяца(Период); 
		КонецЕсли;
		
		Строка.ВсегоЗанятоЧасовВМесяц = ЧасыМесяц;
				
		Если Часы=0 					Тогда Статус = 1 
		ИначеЕсли Часы >0 И Часы < 8 	Тогда Статус = 3
		ИначеЕсли Часы = 8 				Тогда Статус = 4
		ИначеЕсли Часы >8 			 	Тогда Статус = 2		
		КонецЕсли; 
		Строка.СтатусЗанятостьВДень = Статус;
		
	КонецЦикла; 
	
	ЭтаФорма.Модифицированность = Истина;
	ПланированиеТРЗМодифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ПеренестиДанныеВРегистрПланированиеТРЗНаСервере()
			
	Набор = РегистрыСведений.ПланированиеТРЗ.СоздатьНаборЗаписей();
	Набор.Отбор.СсылкаНаДокумент.Установить(Объект.Ссылка);
	Набор.Записать(Истина);
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УправлениеЗадачейПланированиеТРЗ.Период,
		|	УправлениеЗадачейПланированиеТРЗ.Исполнитель,
		|	УправлениеЗадачейПланированиеТРЗ.Часы,
		|	УправлениеЗадачейПланированиеТРЗ.Статус,
		|	УправлениеЗадачейПланированиеТРЗ.Комментарий
		|ИЗ
		|	Документ.УправлениеЗадачей.ПланированиеТРЗ КАК УправлениеЗадачейПланированиеТРЗ
		|ГДЕ
		|	УправлениеЗадачейПланированиеТРЗ.Ссылка = &Ссылка";
		
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МенеджерЗаписи = РегистрыСведений.ПланированиеТРЗ.СоздатьМенеджерЗаписи(); 
		МенеджерЗаписи.ТипЗадачи = Объект.Заявка.Тип;  
		МенеджерЗаписи.Заявка = Объект.Заявка; 
		МенеджерЗаписи.Период = ВыборкаДетальныеЗаписи.Период; 
		МенеджерЗаписи.Исполнитель = ВыборкаДетальныеЗаписи.Исполнитель;
		МенеджерЗаписи.Часы = ВыборкаДетальныеЗаписи.Часы;
		МенеджерЗаписи.СсылкаНаДокумент = Объект.Ссылка;
		МенеджерЗаписи.Статус = ВыборкаДетальныеЗаписи.Статус;
		МенеджерЗаписи.Комментарий = ВыборкаДетальныеЗаписи.Комментарий;
		
		МенеджерЗаписи.Записать();
	КонецЦикла;
			
КонецПроцедуры

&НаКлиенте
Функция ПеренестиДанныеВРегистрПланированиеТРЗНаКлиенте()
	
	Невыход = Ложь;
	Выходной = Ложь;
	
	Для каждого Строка Из Объект.ПланированиеТРЗ Цикл
	
		Невыход = ПроверкаНевыходов(Строка.Период, Строка.Исполнитель);	
		Выходной = ПроверкаГрафикаРаботы(Строка.Период, Строка.Исполнитель);
		
	КонецЦикла;           	
	
	Если Не Невыход И Не Выходной Тогда
	
		ПеренестиДанныеВРегистрПланированиеТРЗНаСервере();
		ОбновитьСтрокиНаКлиенте();
		Возврат Истина;
	Иначе
		Возврат Ложь;				
	КонецЕсли;  
			
КонецФункции

&НаСервере
Функция ПланированиеТРЗПериодПриИзмененииНаСервере(Период,Исполнитель)
	    			
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СУММА(ПланированиеТРЗ.Часы)
		|ИЗ
		|	РегистрСведений.ПланированиеТРЗ КАК ПланированиеТРЗ
		|ГДЕ
		|	ПланированиеТРЗ.Исполнитель = &Исполнитель
		|	И ПланированиеТРЗ.Период = &Период";
	
	Запрос.УстановитьПараметр("Исполнитель", Исполнитель);
	Запрос.УстановитьПараметр("Период", Период);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Часы = 0;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Часы = ВыборкаДетальныеЗаписи.Часы;
	КонецЦикла;
	    	
	Возврат Часы;
	
КонецФункции

&НаКлиенте
Процедура ПланированиеТРЗПериодПриИзменении(Элемент)
	
	Период = Дата(Элемент.ТекстРедактирования+ " 00:00:00");
	Исполнитель = ЭтаФорма.ТекущийЭлемент.ТекущиеДанные.Исполнитель;
	ВсегоЗанятоЧасовВДень = ПланированиеТРЗПериодПриИзмененииНаСервере(Период,Исполнитель);
	ЭтаФорма.ТекущийЭлемент.ТекущиеДанные.ВсегоЗанятоЧасовВДень = ВсегоЗанятоЧасовВДень;
	
КонецПроцедуры


&НаКлиенте
Процедура СтатусПриИзменении(Элемент)
	
	СтатусПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура СтатусПриИзмененииНаСервере()
		
	Если Объект.Статус = Справочники.Статусы.ВРаботе Тогда
		Элементы.ЭтапыРеализации.Видимость = Истина;	
		ДатаРелизаПриИзмененииНаСервере();
	Иначе
		Элементы.ЭтапыРеализации.Видимость = Ложь;	
	КонецЕсли;	
	
	Если Объект.Статус = Справочники.Статусы.Выполнено Тогда
		Объект.РаботыВыполнены = Истина;
	Иначе 
		Объект.РаботыВыполнены = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаРелизаПриИзменении(Элемент)
	
	ДатаРелизаПриИзмененииНаСервере();

КонецПроцедуры

&НаСервере
Процедура ДатаРелизаПриИзмененииНаСервере()
	
	Если НЕ Объект.ДатаПереносаВПродуктив = Дата("00010101000000") Тогда	
		
		Элементы.Тестирование.Заголовок = "Тестирование "+Строка(Формат(Объект.ДатаПереносаВПродуктив+Справочники.КонстантыРасчетаЭтапов.Тестирование.Значение*86400,"ДЛФ=ДД"));
		Элементы.Согласование.Заголовок = "Согласование кода "+Строка(Формат(Объект.ДатаПереносаВПродуктив+Справочники.КонстантыРасчетаЭтапов.СогласованиеКода.Значение*86400,"ДЛФ=ДД"));
		Элементы.ПереносВХранилище.Заголовок = "Перенос в хранилище "+Строка(Формат(Объект.ДатаПереносаВПродуктив+Справочники.КонстантыРасчетаЭтапов.ПереносВХранилище.Значение*86400,"ДЛФ=ДД"));
		Элементы.Настройка.Заголовок = "Настройка "+Строка(Формат(Объект.ДатаПереносаВПродуктив+Справочники.КонстантыРасчетаЭтапов.Настройка.Значение*86400,"ДЛФ=ДД"));
				
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИнтеграцияПриИзменении(Элемент)
	
	ИнтеграцияПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ИнтеграцияПриИзмененииНаСервере()
	
	Элементы.ИнтеграцияНадпись.Заголовок = ?(Объект.Интеграция,"Учитывать трудозатраты смежников","");
	
КонецПроцедуры

&НаКлиенте
Процедура ПланированиеТРЗПриИзменении(Элемент)
	ПланированиеТРЗМодифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ПроцентПодготовкиТЗПриИзменении(Элемент)
	Если Объект.ПроцентПодготовкиТЗ = 100 Тогда
		Элементы.ПроцентПодготовкиДО.ТолькоПросмотр = Ложь;
	Иначе
		Элементы.ПроцентПодготовкиДО.ТолькоПросмотр = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПроцентПодготовкиДОПриИзменении(Элемент)
	Если Объект.ПроцентПодготовкиДо = 100 Тогда
		Элементы.ПроцентВыполнения.ТолькоПросмотр = Ложь;
	Иначе
		Элементы.ПроцентВыполнения.ТолькоПросмотр = Истина;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПроверкаТРЗМесяцНаСервере(Период, Исполнитель)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НАЧАЛОПЕРИОДА(ПланированиеТРЗСрезПоследних.Период, МЕСЯЦ) КАК Период,
		|	СУММА(ПланированиеТРЗСрезПоследних.Часы) КАК Часы
		|ИЗ
		|	РегистрСведений.ПланированиеТРЗ КАК ПланированиеТРЗСрезПоследних
		|ГДЕ
		|	ПланированиеТРЗСрезПоследних.Исполнитель = &Исполнитель
		|	И ПланированиеТРЗСрезПоследних.Период >= &Начало
		|	И ПланированиеТРЗСрезПоследних.Период <= &Окончание
		|
		|СГРУППИРОВАТЬ ПО
		|	НАЧАЛОПЕРИОДА(ПланированиеТРЗСрезПоследних.Период, МЕСЯЦ)";
	
	Запрос.УстановитьПараметр("Исполнитель", Исполнитель);
	Запрос.УстановитьПараметр("Начало",НачалоМесяца(Период));
	Запрос.УстановитьПараметр("Окончание", КонецМесяца(Период));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
	ЧасыМесяц = 0;
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ЧасыМесяц = ВыборкаДетальныеЗаписи.Часы;
	КонецЦикла;
	    	
	Возврат ЧасыМесяц;

КонецФункции

&НаСервере
Функция ПроверкаНевыходов(Период, Исполнитель) 

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НевыходыИсполнителей.Исполнитель,
	|	НевыходыИсполнителей.ВидДня
	|ИЗ
	|	РегистрСведений.НевыходыИсполнителей КАК НевыходыИсполнителей
	|ГДЕ
	|	НевыходыИсполнителей.Период = &Период
	|	И НевыходыИсполнителей.Исполнитель = &Исполнитель";
	
	Запрос.УстановитьПараметр("Период", Период);
	Запрос.УстановитьПараметр("Исполнитель", Исполнитель);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Невыход = Ложь;
	
	Если ВыборкаДетальныеЗаписи.Количество()>0 Тогда
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			ВидДня = ВыборкаДетальныеЗаписи.ВидДня;
		КонецЦикла;
		Сообщить("На дату "+ Период +" у исполнителя " + Исполнитель + " назначен "+ ВидДня +"!");
		Невыход =  Истина;		
	КонецЕсли;
	
	Возврат Невыход;
	
КонецФункции

&НаСервере
Функция ПроверкаГрафикаРаботы(Период, Исполнитель)

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	КалендарьГрафиковРаботы.Исполнитель,
	|	КалендарьГрафиковРаботы.ВидВремениРаботы,
	|	КалендарьГрафиковРаботы.КоличествоРабочихЧасов
	|ИЗ
	|	РегистрСведений.КалендарьГрафиковРаботы КАК КалендарьГрафиковРаботы
	|ГДЕ
	|	КалендарьГрафиковРаботы.Исполнитель = &Исполнитель
	|	И КалендарьГрафиковРаботы.Период = &Период";
	
	Запрос.УстановитьПараметр("Период", Период);
	Запрос.УстановитьПараметр("Исполнитель", Исполнитель);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Выходной = Ложь;
	
	Если ВыборкаДетальныеЗаписи.Количество()>0 Тогда
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если ВыборкаДетальныеЗаписи.ВидВремениРаботы = Перечисления.ВидыВремениРаботы.Выходной Тогда
				Выходной = Истина;
				Сообщить("На дату "+ Период +" у исполнителя " + Исполнитель + " стоит выходной!");
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;	
	
	Возврат Выходной;
	
КонецФункции



