﻿using System;
using System.Collections.Generic;
using System.Text;

namespace eQACoLTD.ViewModel.Product.Stock.Handlers
{
    public class ImportPurchaseOrderDto
    {
        private DateTime importDate;
        public DateTime ImportDate { get=>importDate;
            set
            {
                importDate = value.ToLocalTime();
            }
        }
        public string Description { get; set; }
        public string StockActionId { get; set; }
        public string WarehouseId { get; set; }

    }
}
