USE [DAX2012_DS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author     : rSeyt
-- Create date: 23.09.2020
-- Description: Ожидаемые поставки RPAS (список незавершенных заказов в аксапте)
-- project    : GSS_INC_19628_rSeyt
-- =============================================
ALTER PROCEDURE [dbo].[rpas_exp_ExpectedDlv]
(
  @ExpType                      int          = 0     -- 0 - Полная выгрузка, 1 - изменения
, @SaveLog                      bit          = 0     -- 0 - не сохранять лог, 1 - сохранять ход выполнения в лог
, @CalcPurch                    bit          = 1     -- 0 - не анализировать Покупки, 1 - обрабатывать Покупки
, @CalcTransfer                 bit          = 1     -- 0 - не анализировать Перемещения, 1 - обрабатывать Перемещения
, @SaveInDaxPBD                 bit          = 1     -- 0 - не сохранять изменения, 1 - сохранять изменения в таблице dbo.RPASExpectedDlvPBD
, @ExecPBDQuery                 bit          = 1     -- 0 - не выполнять, 1 - выполнить запрос в ПБД

, @CurDate                      date         = null  -- доп.фильтр. Заданная дата Х вместо системной
, @Vend                         nvarchar(20) = N''   -- доп.фильтр. Все данные, кроме данных этого поставщика будут удалены при отборе данных
, @InventLocationIdFrom         nvarchar(20) = N''   -- доп.фильтр. Все данные, кроме данных этого складаОткуда будут удалены при отборе данных
, @InventLocationIdTo           nvarchar(20) = N''   -- доп.фильтр. Все данные, кроме данных этого СкладаКуда будут удалены при отборе данных
, @PurchId                      nvarchar(20) = N''   -- доп.фильтр. Все данные, кроме данных этой покупки будут удалены при отборе данных
, @TransferId                   nvarchar(20) = N''   -- доп.фильтр. Все данные, кроме данных этого перемещения будут удалены при отборе данных
, @ShowPurch                    bit          = 0     -- 0 - не показывать, 1 - показать данные таблицы #Purch
, @ShowTransfer                 bit          = 0     -- 0 - не показывать, 1 - показать данные таблицы #Transfer
, @ShowDCProcessPeriods         bit          = 0     -- 0 - не показывать, 1 - показать данные таблиц #DCProcessRecId, #DCProcessRecIdAll
, @ShowPurchLineSubPurch        bit          = 0     -- 0 - не показывать, 1 - показать данные таблицы #PurchLine по ПЗК
)

select top 1 @RPASExpectedDlvHistoryDays    = t.RPASExpectedDlvHistoryDays, 
			 @RPASExpectedDlvHistoryDaysPBL = t.RPASExpectedDlvHistoryDaysPBL  from dbo.IntegrationParameters as t;
    
if ( @RPASExpectedDlvHistoryDays is null or @RPASExpectedDlvHistoryDays < 0) RAISERROR('В параметрах управления запасами не указано Количество дней в прошлом для выгрузки ожидаемых поставок в RPAS', 16, 6) WITH NOWAIT;
