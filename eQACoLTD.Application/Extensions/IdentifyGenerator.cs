﻿using eQACoLTD.ViewModel.Customer.Handlers;
using eQACoLTD.ViewModel.Product.ListProduct.Handlers;
using eQACoLTD.ViewModel.System.Employee.Handlers;
using System;
using System.Collections.Generic;
using System.Text;

namespace eQACoLTD.Application.Extensions
{
    public static class IdentifyGenerator
    {
        public static string GenerateCustomerId(int sequenceNumber)
        {
            string id = string.Format("CUS{0}", sequenceNumber.ToString().PadLeft(4, '0'));
            return id;
        }

        public static string GenerateEmployeeId(int sequenceNumber)
        {
            string id = string.Format("EPN{0}", sequenceNumber.ToString().PadLeft(4, '0'));
            return id;
        }

        public static string GenerateProductId(int sequenceNumber)
        {
            string id = string.Format("PRN{0}", sequenceNumber.ToString().PadLeft(4, '0'));
            return id;
        }
        public static string GenerateSupplierId(int sequenceNumber)
        {
            string id = string.Format("SUN{0}", sequenceNumber.ToString().PadLeft(4, '0'));
            return id;
        }
    }
}
