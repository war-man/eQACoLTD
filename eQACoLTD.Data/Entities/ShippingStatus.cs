﻿using System;
using System.Collections.Generic;
using System.Text;

namespace eQACoLTD.Data.Entities
{
    public class ShippingStatus
    {
        public string Id { get; set; }
        public string Name { get; set; }

        public List<ShippingOrder> ShippingOrders { get; set; }
    }
}