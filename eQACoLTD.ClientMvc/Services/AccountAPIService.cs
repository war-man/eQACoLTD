﻿using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using eQACoLTD.ViewModel.Common;
using eQACoLTD.ViewModel.System.Account.Queries;
using Newtonsoft.Json;

namespace eQACoLTD.ClientMvc.Services
{
    public class AccountAPIService:IAccountAPIService
    {
        private readonly IHttpClientFactory _httpClientFactory;
        public AccountAPIService(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }
        public async Task<ApiResult<int>> AddProductToCart(string productId)
        {
            var httpClient = _httpClientFactory.CreateClient("APIClient");
            var json = JsonConvert.SerializeObject(productId);
            var httpContent=new StringContent(json,Encoding.UTF8,"application/json");
            var response = await httpClient.PostAsync("api/accounts/carts",httpContent);
            if (response.IsSuccessStatusCode)
            {
                return new ApiResult<int>(HttpStatusCode.OK)
                {
                    ResultObj = JsonConvert.DeserializeObject<int>
                        (await response.Content.ReadAsStringAsync())
                };
            }
            return new ApiResult<int>(response.StatusCode);
        }

        public async Task<ApiResult<CartDto>> GetCart()
        {
            var httpClient = _httpClientFactory.CreateClient("APIClient");
            var response = await httpClient.GetAsync("api/accounts/carts");
            if (response.IsSuccessStatusCode)
            {
                return new ApiResult<CartDto>(HttpStatusCode.OK)
                {
                    ResultObj = JsonConvert.DeserializeObject<CartDto>
                        (await response.Content.ReadAsStringAsync())
                };
            }
            return new ApiResult<CartDto>(response.StatusCode);
        }
    }
}