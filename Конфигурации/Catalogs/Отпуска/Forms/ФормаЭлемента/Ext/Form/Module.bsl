﻿

&НаКлиенте
Процедура ВидДняОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Если ВыбранноеЗначение = ЗначениеОтпуск() Тогда
		Объект.Наименование = "Отпуск";
	Иначе  Объект.Наименование = "Больничный";
 	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ЗначениеОтпуск()
	Возврат Перечисления.ВидыВыходногоДня.Отпуск;
КонецФункции

