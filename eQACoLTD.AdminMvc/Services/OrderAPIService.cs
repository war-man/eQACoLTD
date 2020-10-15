﻿using System.Net.Http;
using System.Threading.Tasks;
using eQACoLTD.ViewModel.Common;
using eQACoLTD.ViewModel.Order.Queries;
using eQACoLTD.ViewModel.Product.Category.Queries;
using Newtonsoft.Json;

namespace eQACoLTD.AdminMvc.Services
{
    public class OrderAPIService:IOrderAPIService
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public OrderAPIService(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }
        public async Task<ApiResult<PagedResult<OrdersDto>>> GetOrdersPagingAsync(int pageIndex, int pageSize)
        {
            var httpClient = _httpClientFactory.CreateClient("APIClient");
            var response = await httpClient.GetAsync($"api/orders?pageIndex={pageIndex}&pageSize={pageSize}");
            if (response.IsSuccessStatusCode)
            {
                return new ApiResult<PagedResult<OrdersDto>>(System.Net.HttpStatusCode.OK) { 
                    ResultObj= JsonConvert.DeserializeObject<PagedResult<OrdersDto>>
                        (await response.Content.ReadAsStringAsync())
                };
            }
            return new ApiResult<PagedResult<OrdersDto>>(response.StatusCode, await response.Content.ReadAsStringAsync());
        }

        public async Task<ApiResult<OrderDto>> GetOrderAsync(string orderId)
        {
            var httpClient = _httpClientFactory.CreateClient("APIClient");
            var response = await httpClient.GetAsync($"api/orders/"+orderId);
            if (response.IsSuccessStatusCode)
            {
                return new ApiResult<OrderDto>(System.Net.HttpStatusCode.OK) { 
                    ResultObj= JsonConvert.DeserializeObject<OrderDto>
                        (await response.Content.ReadAsStringAsync())
                };
            }
            return new ApiResult<OrderDto>(response.StatusCode, await response.Content.ReadAsStringAsync());
        }
    }
}