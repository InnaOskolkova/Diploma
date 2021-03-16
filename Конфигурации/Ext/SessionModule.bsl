﻿//Установка текущего пользователя сеанса
Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	ТекущийПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	Если Справочники.Исполнители.НайтиПоНаименованию(ТекущийПользователь.ПолноеИмя) <> Неопределено Тогда 
		ПараметрыСеанса.ТекущийПользователь = Справочники.Исполнители.НайтиПоНаименованию(ТекущийПользователь.ПолноеИмя);
	Иначе
		ПараметрыСеанса.ТекущийПользователь = Справочники.Координаторы.НайтиПоНаименованию(ТекущийПользователь.ПолноеИмя);
	КонецЕсли;
КонецПроцедуры
