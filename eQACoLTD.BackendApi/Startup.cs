using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using AutoMapper;
using EmailService;
using eQACoLTD.Application.Customer;
using eQACoLTD.Application.Extensions;
using eQACoLTD.Application.Order;
using eQACoLTD.Application.Others;
using eQACoLTD.Application.Product.Category;
using eQACoLTD.Application.Product.ListProduct;
using eQACoLTD.Application.Product.Payment;
using eQACoLTD.Application.Product.PurchaseOrder;
using eQACoLTD.Application.Product.Stock;
using eQACoLTD.Application.Product.Supplier;
using eQACoLTD.Application.Report;
using eQACoLTD.Application.System.Account;
using eQACoLTD.Application.System.Employee;
using eQACoLTD.BackendApi.Configurations;
using eQACoLTD.BackendApi.Extensions;
using eQACoLTD.Data.DBContext;
using eQACoLTD.Data.Entities;
using eQACoLTD.Utilities.Extensions;
using IdentityServer4.AccessTokenValidation;
using LoggerService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Logging;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace eQACoLTD.BackendApi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var emailConfig = Configuration.GetSection("EmailConfiguration")
                .Get<EmailConfiguration>();
            services.AddSingleton(emailConfig);
            services.AddScoped<IEmailSender, EmailSender>();
            services.AddDbContext<AppIdentityDbContext>(options =>
               options.UseSqlServer(Configuration["ConnectionStrings:DefaultConnection"]));
            services.AddCors(options => options.AddPolicy("CorsPolicy", builder => builder.AllowAnyMethod()
               .AllowAnyHeader()
               .WithOrigins(Configuration["AdminMvc"], Configuration["ClientMvc"]).AllowCredentials()));
            services.AddTransient<UserManager<AppUser>, UserManager<AppUser>>();
            services.AddTransient<SignInManager<AppUser>, SignInManager<AppUser>>();
            services.AddTransient<RoleManager<AppRole>, RoleManager<AppRole>>();

            services.AddAuthentication(IdentityServerAuthenticationDefaults.AuthenticationScheme)
                .AddJwtBearer(IdentityServerAuthenticationDefaults.AuthenticationScheme,options =>
                {
                    options.Authority = Configuration["IdentityServerHost"];
                    options.Audience = Configuration["Audience"];
                    options.RequireHttpsMetadata = false;
                });

            services.AddIdentity<AppUser, AppRole>()
               .AddEntityFrameworkStores<AppIdentityDbContext>()
               .AddDefaultTokenProviders();

            services.AddControllers().AddNewtonsoftJson();
            services.AddAutoMapper(typeof(AutoMapperProfile).Assembly);
            services.AddSwaggerGen(options =>
            {
                options.SwaggerDoc("v1", new OpenApiInfo { Title = "Protected Backend API", Version = "v1" });

                options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
                {
                    Type = SecuritySchemeType.OAuth2,
                    Flows = new OpenApiOAuthFlows
                    {
                        AuthorizationCode = new OpenApiOAuthFlow
                        {
                            AuthorizationUrl = new Uri(Configuration["IdentityServerHost"]+"/connect/authorize"),
                            TokenUrl = new Uri(Configuration["IdentityServerHost"]+"/connect/token"),
                            Scopes = new Dictionary<string, string>
                            {
                                {"backend_api", "Backend API - full access"}
                            }
                        }
                    }
                });

                options.OperationFilter<AuthorizeCheckOperationFilter>();
            });
            services.AddScoped<ILoggerManager, LoggerManager>();
            services.AddScoped<IStorageService, FileStorageService>();
            services.AddTransient<IAccountService, AccountService>();
            services.AddTransient<IEmployeeService,EmployeeService>();
            services.AddTransient<ICategoryService,CategoryService>();
            services.AddTransient<ISupplierService,SupplierService>();
            services.AddTransient<IListProductService,ListProductService>();
            services.AddTransient<ICustomerService,CustomerService>();
            services.AddTransient<IOtherService, OtherService>();
            services.AddTransient<IOrderService, OrderService>();
            services.AddTransient<IStockService, StockService>();
            services.AddTransient<IPaymentService, PaymentService>();
            services.AddTransient<IReportService,ReportService>();
            services.AddTransient<IPurchaseOrderService, PurchaseOrderSerivce>();
            services.AddScoped<AppIdentityDbContext,AppIdentityDbContext>();

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env,ILoggerManager loggerManager)
        {
            app.UseCors("CorsPolicy");
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.ConfigureExceptionHandler(loggerManager);

            app.UseHttpsRedirection();
            app.UseStaticFiles();
                
            app.UseCors();
            app.UseRouting();
            app.UseAuthentication();

            app.UseAuthorization();

            app.UseSwagger();

            app.UseSwaggerUI(options =>
            {
                options.SwaggerEndpoint("/swagger/v1/swagger.json", "Backend API V1");

                options.OAuthClientId("backend_api_swagger");
                options.OAuthAppName("Backend API - Swagger");
                options.OAuthUsePkce();
            });

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
    public class AuthorizeCheckOperationFilter : IOperationFilter
    {
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            var hasAuthorize = context.MethodInfo.DeclaringType.GetCustomAttributes(true).OfType<AuthorizeAttribute>().Any() ||
                               context.MethodInfo.GetCustomAttributes(true).OfType<AuthorizeAttribute>().Any();

            if (hasAuthorize)
            {
                operation.Responses.Add("401", new OpenApiResponse { Description = "Unauthorized" });
                operation.Responses.Add("403", new OpenApiResponse { Description = "Forbidden" });

                operation.Security = new List<OpenApiSecurityRequirement>
                {
                    new OpenApiSecurityRequirement
                    {
                        [new OpenApiSecurityScheme {Reference = new OpenApiReference {Type = ReferenceType.SecurityScheme, Id = "oauth2"}}]
                            = new[] {"backend_api"}
                    }
                };
            }
        }
    }
}
