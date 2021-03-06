USE [master]
GO
/****** Object:  Database [DB_eQACoLTD]    Script Date: 9/17/2020 7:38:43 AM ******/
CREATE DATABASE [DB_eQACoLTD]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DB_eQACoLTD', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\DB_eQACoLTD.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DB_eQACoLTD_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\DB_eQACoLTD_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [DB_eQACoLTD] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DB_eQACoLTD].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DB_eQACoLTD] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET ARITHABORT OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [DB_eQACoLTD] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DB_eQACoLTD] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DB_eQACoLTD] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET  ENABLE_BROKER 
GO
ALTER DATABASE [DB_eQACoLTD] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DB_eQACoLTD] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [DB_eQACoLTD] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DB_eQACoLTD] SET  MULTI_USER 
GO
ALTER DATABASE [DB_eQACoLTD] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DB_eQACoLTD] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DB_eQACoLTD] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DB_eQACoLTD] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [DB_eQACoLTD] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [DB_eQACoLTD] SET QUERY_STORE = OFF
GO
USE [DB_eQACoLTD]
GO
/****** Object:  UserDefinedFunction [dbo].[fuGetCustomerDebt]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fuGetCustomerDebt]
(@customerId varchar(12))
returns decimal
as
begin
	declare @total_debt decimal;
	set @total_debt=(
		(select ISNULL(SUM(OrderDetails.Quantity*OrderDetails.UnitPrice),0) from OrderDetails 
		inner join Orders on Orders.Id=OrderDetails.OrderId where Orders.CustomerId=@customerId) - 
		(select ISNULL(SUM(ReceiptVouchers.Received),0) from ReceiptVouchers 
		inner join Orders on ReceiptVouchers.OrderId=Orders.Id where Orders.CustomerId=@customerId)+
		(select ISNULL(Sum(PaymentVouchers.Paid),0) from PaymentVouchers where PaymentVouchers.CustomerId=@customerId)
	);
	return ISNULL(@total_debt,0);
end;

---Lấy lịch sử mua hàng của khách hàng phân trang
GO
/****** Object:  UserDefinedFunction [dbo].[fuGetSupplierDebt]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fuGetSupplierDebt]
(@supplier_id varchar(12))
returns decimal
as
begin
	declare @total_debt decimal;
	set @total_debt=(
	(select ISNULL(SUM(Quantity*UnitPrice),0) from PurchaseOrderDetails 
	inner join PurchaseOrders on PurchaseOrders.Id=PurchaseOrderDetails.PurchaseOrderId 
	where PurchaseOrders.SupplierId=@supplier_id)-
	(select ISNULL(SUM(Paid),0) from PaymentVouchers 
	inner join PurchaseOrders on PurchaseOrders.Id=PaymentVouchers.PurchaseOrderId 
	where PurchaseOrders.SupplierId=@supplier_id)
	+(select ISNULL(SUM(ReceiptVouchers.Received),0) from ReceiptVouchers where ReceiptVouchers.SupplierId=@supplier_id));
	return ISNULL(@total_debt,0);
end;
---Lấy danh sách nhà cung cấp phân trang
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppRoleClaims]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppRoleClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AppRoleClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppRoles]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppRoles](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[NormalizedName] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[Description] [nvarchar](250) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[FromDate] [datetime2](7) NOT NULL,
	[ToDate] [datetime2](7) NOT NULL,
	[AppUserId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AppRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUserClaims]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AppUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUserLogins]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUserLogins](
	[UserId] [uniqueidentifier] NOT NULL,
	[LoginProvider] [nvarchar](max) NULL,
	[ProviderKey] [nvarchar](max) NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
 CONSTRAINT [PK_AppUserLogins] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUserRoles]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUserRoles](
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AppUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUsers]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUsers](
	[Id] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](max) NULL,
	[NormalizedUserName] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL,
	[NormalizedEmail] [nvarchar](max) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_AppUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUserTokens]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUserTokens](
	[UserId] [uniqueidentifier] NOT NULL,
	[LoginProvider] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_AppUserTokens] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Brands]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brands](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[ImagePath] [nvarchar](max) NULL,
 CONSTRAINT [PK_Brands] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Carts]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Carts](
	[UserId] [uniqueidentifier] NOT NULL,
	[ProductId] [varchar](12) NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_Carts] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[ThumbnailImagePath] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[Id] [varchar](12) NOT NULL,
	[Dob] [datetime2](7) NOT NULL,
	[FullName] [nvarchar](200) NOT NULL,
	[Address] [nvarchar](300) NULL,
	[Gender] [bit] NULL,
	[AvatarPath] [nvarchar](1000) NULL,
	[IsDelete] [bit] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[CustomerTypeId] [char](36) NULL,
	[DefaultPhoneNumber] [varchar](30) NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerTypes]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerTypes](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_CustomerTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DiscountTypes]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscountTypes](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](150) NULL,
 CONSTRAINT [PK_DiscountTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[Id] [varchar](12) NOT NULL,
	[Dob] [datetime2](7) NOT NULL,
	[FullName] [nvarchar](200) NOT NULL,
	[Address] [nvarchar](300) NULL,
	[Gender] [bit] NULL,
	[AvatarPath] [nvarchar](max) NULL,
	[IsDelete] [bit] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[DefaultPhoneNumber] [varchar](30) NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[Id] [char](36) NOT NULL,
	[OrderId] [varchar](12) NULL,
	[ProductId] [varchar](12) NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[ServiceName] [nvarchar](300) NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[Id] [varchar](12) NOT NULL,
	[CustomerId] [varchar](12) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[Note] [nvarchar](500) NULL,
	[OrderStatusId] [char](36) NULL,
	[PaymentStatusId] [char](36) NULL,
	[IsDelete] [bit] NOT NULL,
	[DiscountTypeId] [char](36) NULL,
	[DiscountValue] [decimal](18, 0) NOT NULL,
	[DiscountDescription] [nvarchar](500) NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderStatuses]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderStatuses](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_OrderStatuses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentMethods]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentMethods](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_PaymentMethods] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentStatuses]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentStatuses](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_PaymentStatuses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentVouchers]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentVouchers](
	[Id] [varchar](12) NOT NULL,
	[PurchaseOrderId] [varchar](12) NULL,
	[Paid] [decimal](18, 2) NOT NULL,
	[PayDate] [datetime2](7) NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[PaymentMethodId] [char](36) NULL,
	[Description] [nvarchar](250) NULL,
	[CustomerId] [varchar](12) NULL,
	[SupplierId] [varchar](12) NULL,
 CONSTRAINT [PK_PaymentVouchers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductImages]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductImages](
	[Id] [char](36) NOT NULL,
	[ProductId] [varchar](12) NULL,
	[ImagePath] [nvarchar](max) NULL,
	[FullPath] [nvarchar](1000) NULL,
	[IsThumbnail] [bit] NOT NULL,
 CONSTRAINT [PK_ProductImages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductReviewReplies]    Script Date: 9/17/2020 7:38:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductReviewReplies](
	[Id] [char](36) NOT NULL,
	[ProductReviewId] [char](36) NULL,
	[UserId] [uniqueidentifier] NULL,
	[Content] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_ProductReviewReplies] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductReviews]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductReviews](
	[Id] [char](36) NOT NULL,
	[ProductId] [varchar](12) NULL,
	[UserId] [uniqueidentifier] NULL,
	[Title] [nvarchar](100) NULL,
	[Content] [nvarchar](500) NULL,
	[StarScore] [tinyint] NOT NULL,
 CONSTRAINT [PK_ProductReviews] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[Id] [varchar](12) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Information] [nvarchar](600) NULL,
	[CategoryId] [char](36) NULL,
	[Description] [nvarchar](max) NULL,
	[Views] [int] NOT NULL,
	[RetailPrice] [decimal](18, 2) NOT NULL,
	[WholesalePrices] [decimal](18, 2) NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[BrandId] [char](36) NULL,
	[StarScore] [tinyint] NOT NULL,
	[WarrantyPeriod] [tinyint] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PurchaseOrderDetails]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrderDetails](
	[Id] [char](36) NOT NULL,
	[PurchaseOrderId] [varchar](12) NULL,
	[ProductId] [varchar](12) NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[CostName] [nvarchar](400) NULL,
 CONSTRAINT [PK_PurchaseOrderDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PurchaseOrders]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurchaseOrders](
	[Id] [varchar](12) NOT NULL,
	[Note] [nvarchar](250) NULL,
	[SupplierId] [varchar](12) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[PurchaseDate] [datetime2](7) NOT NULL,
	[OrderStatusId] [char](36) NULL,
	[DeliveryDate] [datetime2](7) NOT NULL,
	[PaymentStatusId] [char](36) NULL,
	[IsDelete] [bit] NOT NULL,
	[DiscountTypeId] [char](36) NULL,
	[DiscountValue] [decimal](18, 0) NOT NULL,
	[DiscountDescription] [nvarchar](500) NULL,
 CONSTRAINT [PK_PurchaseOrders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReceiptVouchers]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReceiptVouchers](
	[Id] [varchar](12) NOT NULL,
	[OrderId] [varchar](12) NULL,
	[Received] [decimal](18, 2) NOT NULL,
	[ReceivedDate] [datetime2](7) NOT NULL,
	[PaymentMethodId] [char](36) NULL,
	[IsDelete] [bit] NOT NULL,
	[Description] [nvarchar](250) NULL,
	[SupplierId] [varchar](12) NULL,
	[CustomerId] [varchar](12) NULL,
 CONSTRAINT [PK_ReceiptVouchers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShippingOrders]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingOrders](
	[OrderId] [varchar](12) NOT NULL,
	[ShippingId] [varchar](20) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[CustomerId] [varchar](12) NULL,
	[CustomerName] [nvarchar](150) NULL,
	[PhoneNumber] [varchar](30) NULL,
	[Fee] [decimal](18, 2) NOT NULL,
	[TransporterId] [char](36) NULL,
	[Address] [varchar](300) NULL,
	[ShippingStatusId] [char](36) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ShippingOrders] PRIMARY KEY CLUSTERED 
(
	[OrderId] ASC,
	[ShippingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShippingStatus]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingStatus](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_ShippingStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockActions]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockActions](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_StockActions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StockHistories]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockHistories](
	[Id] [char](36) NOT NULL,
	[ProductId] [varchar](12) NULL,
	[RecordDate] [datetime2](7) NOT NULL,
	[EmployeeId] [varchar](12) NULL,
	[StockActionId] [char](36) NULL,
	[ChangeQuantity] [int] NOT NULL,
	[PurchaseOrderDetailId] [char](36) NULL,
	[OrderDetailId] [char](36) NULL,
 CONSTRAINT [PK_StockHistories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stocks]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stocks](
	[ProductId] [varchar](12) NOT NULL,
	[AbleToSale] [int] NOT NULL,
	[Inventory] [int] NOT NULL,
 CONSTRAINT [PK_Stocks] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[Id] [varchar](12) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Address] [nvarchar](300) NULL,
	[PhoneNumber] [varchar](30) NULL,
	[IsDelete] [bit] NOT NULL,
	[Email] [varchar](150) NULL,
	[Fax] [varchar](30) NULL,
	[EmployeeId] [varchar](12) NULL,
	[Website] [varchar](150) NULL,
	[Description] [varchar](250) NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Transporters]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transporters](
	[Id] [char](36) NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[PhoneNumber] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Transporters] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20200917000603_InitialDatabase', N'3.1.6')
INSERT [dbo].[AppRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp], [Description], [DateCreated], [FromDate], [ToDate], [AppUserId]) VALUES (N'4c6d9e27-83db-496c-8a5f-16e4d3157428', N'Administrator', N'Administrator', N'8038e01c-976e-484a-94a1-31b2dc838990', N'Quyền quản trị viên', CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), NULL)
INSERT [dbo].[AppRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp], [Description], [DateCreated], [FromDate], [ToDate], [AppUserId]) VALUES (N'04e6d6da-4f72-4b5b-88b9-2b919a9c7b9b', N'WarehouseStaff', N'WarehouseStaff', N'0b08ded1-0043-42b0-b451-1ea60cf988ab', N'Quyền nhân viên kho', CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), NULL)
INSERT [dbo].[AppRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp], [Description], [DateCreated], [FromDate], [ToDate], [AppUserId]) VALUES (N'8e06e692-467e-4003-a2de-ad4d3ca1dc6d', N'Receptionist', N'Receptionist', N'4601d24a-8e24-4630-8963-9571f190c898', N'Quyền nhân viên lễ tân', CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), NULL)
INSERT [dbo].[AppRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp], [Description], [DateCreated], [FromDate], [ToDate], [AppUserId]) VALUES (N'b430434f-5cf8-45bc-b25c-e3b123f9e880', N'Cashier', N'Cashier', N'42f52957-e4cd-4f34-964a-ca4e1e7b4ef1', N'Quyền nhân viên thu ngân', CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), CAST(N'0001-01-01T00:00:00.0000000' AS DateTime2), NULL)
INSERT [dbo].[AppUserRoles] ([UserId], [RoleId]) VALUES (N'8efe663c-677d-4bcf-bd59-3359d49bac87', N'4c6d9e27-83db-496c-8a5f-16e4d3157428')
INSERT [dbo].[AppUserRoles] ([UserId], [RoleId]) VALUES (N'4715539a-9f13-4eb0-813b-74d9fda79ccb', N'b430434f-5cf8-45bc-b25c-e3b123f9e880')
INSERT [dbo].[AppUserRoles] ([UserId], [RoleId]) VALUES (N'47a888f4-e5c8-4f07-bd00-fcc7bb531eb3', N'04e6d6da-4f72-4b5b-88b9-2b919a9c7b9b')
INSERT [dbo].[AppUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount], [DateCreated]) VALUES (N'8efe663c-677d-4bcf-bd59-3359d49bac87', N'admin', N'ADMIN', N'dnguyen24498@gmail.com', N'DNGUYEN24498@GMAIL.COM', 1, N'AQAAAAEAACcQAAAAEDmf1wHwhoDBaLUEgbIpPcBNGfhLZF/lDOiuGBLnuWbDlLQU4VwaKow2LCUg0oxK8w==', N'', N'd7a31986-2fbd-4f0a-a931-cba75d0bc593', NULL, 0, 0, NULL, 0, 0, CAST(N'2020-09-17T07:06:02.7149179' AS DateTime2))
INSERT [dbo].[AppUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount], [DateCreated]) VALUES (N'0ee1852e-6396-4f71-86b6-5741def7398b', N'cus0002', N'cus0002', N'dophuongthao@gmail.com', N'DOPHUONGTHAO@GMAIL.COM', 1, N'AQAAAAEAACcQAAAAEPYBVtRgC1wsTPk4i+7KjeJW/A5khZsiKQTjLfCuRQY9elRCPEcohsZNZtqOe7e1QA==', N'', N'1fe1a570-86ca-426d-9d1b-ce5082907919', N'1234567890', 0, 0, NULL, 0, 0, CAST(N'2020-09-17T07:06:02.7149179' AS DateTime2))
INSERT [dbo].[AppUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount], [DateCreated]) VALUES (N'4715539a-9f13-4eb0-813b-74d9fda79ccb', N'epn0001', N'EPN0001', N'duongnguyenadhp1@gmail.com', N'DUONGNGUYENADHP1@GMAIL.COM', 1, N'AQAAAAEAACcQAAAAENjPaMADilW0yqJEzCawN3/iv1AX5TJMOwLjfgmwB7T+odHDJzRcKeDDjHgr0i2HBQ==', N'', N'8af7dd46-7e39-490e-81a5-6ac62076b9fc', N'1234567890', 0, 0, NULL, 0, 0, CAST(N'2020-09-17T07:06:02.7149179' AS DateTime2))
INSERT [dbo].[AppUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount], [DateCreated]) VALUES (N'51098bea-63c8-4aba-8668-84562f5048a0', N'cus0001', N'cus0001', N'duongnguyenadhp@gmail.com', N'DUONGNGUYENADHP@GMAIL.COM', 1, N'AQAAAAEAACcQAAAAEGoeGZpSu10g/D66YuwHWkWq86cRQczioYXlGuDaJttAxbVOW74dimDebry+hVYVvQ==', N'', N'85f1bd56-4b41-4636-89ae-639888042fb6', N'1234567890', 0, 0, NULL, 0, 0, CAST(N'2020-09-17T07:06:02.7149179' AS DateTime2))
INSERT [dbo].[AppUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount], [DateCreated]) VALUES (N'47a888f4-e5c8-4f07-bd00-fcc7bb531eb3', N'epn0002', N'epn0002', N'duongnguyenadhp2@gmail.com', N'DUONGNGUYENADHP2@GMAIL.COM', 1, N'AQAAAAEAACcQAAAAEOuDN+GSMQXUhu5CXHW968LYhxsHGJMHQdannj+9Y5aQqpKHupFxONZPimGu63FpTA==', N'', N'83cc0cb9-48d3-4510-ab7d-bcf5999eb241', N'1234567890', 0, 0, NULL, 0, 0, CAST(N'2020-09-17T07:06:02.7149179' AS DateTime2))
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'01e4179b-1042-489c-8470-984badfd6433', N'Lenovo', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'7d6affea-fde6-4136-a532-0909d68bc802', N'Acer', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'8e64301e-0a6c-48f5-b004-c5c0ffa155f5', N'Logitech', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'992583af-900b-4318-93d5-008326458c4d', N'Razer', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'9d07f19f-afd8-408d-872e-d99331031c59', N'HP', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'af7c139a-02d4-4f24-99c6-d49173de2b19', N'Canon', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'b693eb5a-e457-447c-9e29-48f438703780', N'Dell', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'bedf848d-f7d0-433f-98f1-2731067335af', N'Apple', NULL, NULL)
INSERT [dbo].[Brands] ([Id], [Name], [Description], [ImagePath]) VALUES (N'f1756f5a-bf11-4008-943a-9aa69f40e478', N'Asus', NULL, NULL)
INSERT [dbo].[Categories] ([Id], [Name], [Description], [ThumbnailImagePath]) VALUES (N'2fac847b-9fa2-4e68-803f-9bc331fe5a02', N'Tai nghe', NULL, NULL)
INSERT [dbo].[Categories] ([Id], [Name], [Description], [ThumbnailImagePath]) VALUES (N'3db32842-3ed5-458b-ad96-a113d73775ee', N'Laptop', NULL, NULL)
INSERT [dbo].[Categories] ([Id], [Name], [Description], [ThumbnailImagePath]) VALUES (N'45cb72fd-9ced-4de2-aae8-08dbb42fdbca', N'Bàn phím', NULL, NULL)
INSERT [dbo].[Categories] ([Id], [Name], [Description], [ThumbnailImagePath]) VALUES (N'58060083-6e76-4dea-ba20-0e332ec96122', N'PC', NULL, NULL)
INSERT [dbo].[Categories] ([Id], [Name], [Description], [ThumbnailImagePath]) VALUES (N'9a3f3ba5-76db-434a-acae-18fc90f1e1d6', N'Chuột', NULL, NULL)
INSERT [dbo].[Categories] ([Id], [Name], [Description], [ThumbnailImagePath]) VALUES (N'dabde5d3-3311-4836-8b37-18df01b9a371', N'Máy in', NULL, NULL)
INSERT [dbo].[Customers] ([Id], [Dob], [FullName], [Address], [Gender], [AvatarPath], [IsDelete], [UserId], [CustomerTypeId], [DefaultPhoneNumber]) VALUES (N'CUS0001', CAST(N'1998-04-24T00:00:00.0000000' AS DateTime2), N'Bùi Thùy Dương', N'Số 99, Hải Triều, Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', 0, NULL, 0, N'51098bea-63c8-4aba-8668-84562f5048a0', N'4f2b5d2b-99c0-45a7-abb8-2316e804da63', NULL)
INSERT [dbo].[Customers] ([Id], [Dob], [FullName], [Address], [Gender], [AvatarPath], [IsDelete], [UserId], [CustomerTypeId], [DefaultPhoneNumber]) VALUES (N'CUS0002', CAST(N'1998-04-24T00:00:00.0000000' AS DateTime2), N'Đỗ Phương Thảo', N'Số 99, Hải Triều, Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', 0, NULL, 0, N'0ee1852e-6396-4f71-86b6-5741def7398b', N'4f2b5d2b-99c0-45a7-abb8-2316e804da63', NULL)
INSERT [dbo].[CustomerTypes] ([Id], [Name], [Description], [DateCreated]) VALUES (N'3daf45ee-395b-48c7-a790-247b372d1746', N'Bán buôn', NULL, CAST(N'2020-09-17T07:06:02.7244460' AS DateTime2))
INSERT [dbo].[CustomerTypes] ([Id], [Name], [Description], [DateCreated]) VALUES (N'4f2b5d2b-99c0-45a7-abb8-2316e804da63', N'Bán lẻ', NULL, CAST(N'2020-09-17T07:06:02.7244460' AS DateTime2))
INSERT [dbo].[DiscountTypes] ([Id], [Name]) VALUES (N'0d3c8b87-8010-491b-9867-84805888d937', N'Phần trăm')
INSERT [dbo].[DiscountTypes] ([Id], [Name]) VALUES (N'35d3f8e6-4c28-4315-8e98-5ea957c847c2', N'Tiền mặt')
INSERT [dbo].[Employees] ([Id], [Dob], [FullName], [Address], [Gender], [AvatarPath], [IsDelete], [UserId], [DefaultPhoneNumber]) VALUES (N'EPN0001', CAST(N'1998-04-24T00:00:00.0000000' AS DateTime2), N'Nguyễn Dương Nguyên', N'Số 88, Hải Triều, Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', 1, NULL, 0, N'4715539a-9f13-4eb0-813b-74d9fda79ccb', N'0123456789')
INSERT [dbo].[Employees] ([Id], [Dob], [FullName], [Address], [Gender], [AvatarPath], [IsDelete], [UserId], [DefaultPhoneNumber]) VALUES (N'EPN0002', CAST(N'1998-04-24T00:00:00.0000000' AS DateTime2), N'Bùi Thùy Dương', N'Số 99, Hải Triều, Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', 0, NULL, 0, N'47a888f4-e5c8-4f07-bd00-fcc7bb531eb3', N'0123456789')
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'27f6e5e9-a08c-4470-849b-20b9bc3cef39', N'ODN0002', N'PRN0002', 1, CAST(22500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'2ae60321-773f-48f0-9c66-25179ca216a1', N'ODN0007', N'PRN0007', 1, CAST(9350000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'6006ec40-abb1-4563-aaa5-db40fc8da52c', N'ODN0006', N'PRN0006', 1, CAST(52500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'7c2139ae-ee0b-4e6a-9c48-32428fc4c032', N'ODN0001', N'PRN0001', 1, CAST(22500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'825050ee-defb-4cd2-b57f-bdb0c4a53d2a', N'ODN0008', N'PRN0008', 1, CAST(12350000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'bb2da4f7-ff64-4b90-93b9-4cd77f7b7924', N'ODN0011', N'PRN0011', 1, CAST(32500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'bf5a1cca-3dd8-41a7-89b0-644cd2efc93f', N'ODN0004', N'PRN0004', 1, CAST(42000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'bf690d30-9ec7-4e23-a9ce-57b3598e5354', N'ODN0009', N'PRN0009', 1, CAST(12500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'c18ea094-de2d-4934-b970-2f3d20e24ee5', N'ODN0010', N'PRN0010', 1, CAST(22500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'd0663a4c-52a6-49e6-85f8-462fe06321ac', N'ODN0005', N'PRN0005', 1, CAST(22500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[OrderDetails] ([Id], [OrderId], [ProductId], [Quantity], [UnitPrice], [ServiceName]) VALUES (N'e6f23913-f4b1-4908-9020-230ff2eee264', N'ODN0003', N'PRN0003', 2, CAST(32500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0001', N'CUS0001', CAST(N'2020-09-17T07:06:02.7718124' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0002', N'CUS0002', CAST(N'2020-09-17T07:06:02.7718124' AS DateTime2), NULL, N'43972588-ea79-4bf0-8ed7-7e9ef42170a7', N'6187b25a-957c-4690-ba99-f64499119f35', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0003', N'CUS0001', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0004', N'CUS0001', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0005', N'CUS0001', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0006', N'CUS0001', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0007', N'CUS0001', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0008', N'CUS0002', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0009', N'CUS0002', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0010', N'CUS0002', CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[Orders] ([Id], [CustomerId], [DateCreated], [Note], [OrderStatusId], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'ODN0011', N'CUS0002', CAST(N'2020-09-17T07:29:28.8600000' AS DateTime2), NULL, N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[OrderStatuses] ([Id], [Name]) VALUES (N'43972588-ea79-4bf0-8ed7-7e9ef42170a7', N'Đang giao dịch')
INSERT [dbo].[OrderStatuses] ([Id], [Name]) VALUES (N'537d8259-b206-496a-8a85-29f76539301b', N'Kết thúc')
INSERT [dbo].[OrderStatuses] ([Id], [Name]) VALUES (N'75d76ab9-5e0e-4b42-8bdc-7e3c5d4904a1', N'Đặt hàng')
INSERT [dbo].[OrderStatuses] ([Id], [Name]) VALUES (N'80b1a453-82a4-47ed-964e-1b69af87a1e1', N'Hoàn thành')
INSERT [dbo].[OrderStatuses] ([Id], [Name]) VALUES (N'940195d2-885c-45aa-af98-17ad7549f90a', N'Đã hủy')
INSERT [dbo].[PaymentMethods] ([Id], [Name]) VALUES (N'2107adeb-7574-4f62-a898-22b79b67ee62', N'Quẹt thẻ')
INSERT [dbo].[PaymentMethods] ([Id], [Name]) VALUES (N'a2b931dd-c5be-47c5-a134-f9f3474cf630', N'Tiền mặt')
INSERT [dbo].[PaymentMethods] ([Id], [Name]) VALUES (N'f859d3ef-13e6-411b-b701-d5d643524653', N'Chuyển khoản')
INSERT [dbo].[PaymentStatuses] ([Id], [Name]) VALUES (N'57fa4d1a-974a-4157-bd6c-287db184a51e', N'Chưa thanh toán')
INSERT [dbo].[PaymentStatuses] ([Id], [Name]) VALUES (N'6187b25a-957c-4690-ba99-f64499119f35', N'Thanh toán một phần')
INSERT [dbo].[PaymentStatuses] ([Id], [Name]) VALUES (N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', N'Đã thanh toán')
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0001', N'PON0001', CAST(2250000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:06:02.8120286' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0002', N'PON0002', CAST(500000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:06:02.8121108' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0003', N'PON0003', CAST(2500000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8466667' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0004', N'PON0004', CAST(400000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8466667' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0005', N'PON0005', CAST(2200000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0006', N'PON0006', CAST(520000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0007', N'PON0007', CAST(0.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0008', N'PON0008', CAST(0.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0009', N'PON0009', CAST(120000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0010', N'PON0010', CAST(220000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[PaymentVouchers] ([Id], [PurchaseOrderId], [Paid], [PayDate], [IsDelete], [PaymentMethodId], [Description], [CustomerId], [SupplierId]) VALUES (N'PVN0011', N'PON0011', CAST(320000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), 0, N'a2b931dd-c5be-47c5-a134-f9f3474cf630', NULL, NULL, NULL)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'0f32c3af-e522-44a7-9d33-5d952f0a78d9', N'PRN0019', N'0f32c3af-e522-44a7-9d33-5d952f0a78d9.png', N'https://localhost:5001/app-content/0f32c3af-e522-44a7-9d33-5d952f0a78d9.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'0fa35008-54b0-4e4a-80a5-bcc083213280', N'PRN0026', N'0fa35008-54b0-4e4a-80a5-bcc083213280.png', N'https://localhost:5001/app-content/0fa35008-54b0-4e4a-80a5-bcc083213280.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'1826d2ec-5e91-49c1-98a9-42a20020282b', N'PRN0004', N'1826d2ec-5e91-49c1-98a9-42a20020282b.png', N'https://localhost:5001/app-content/1826d2ec-5e91-49c1-98a9-42a20020282b.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'2dbb493b-0cd7-43cf-85c0-c1621a21c0ed', N'PRN0015', N'2dbb493b-0cd7-43cf-85c0-c1621a21c0ed.png', N'https://localhost:5001/app-content/2dbb493b-0cd7-43cf-85c0-c1621a21c0ed.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'43f2d71f-52fd-4f32-87aa-0d842821e356', N'PRN0011', N'43f2d71f-52fd-4f32-87aa-0d842821e356.png', N'https://localhost:5001/app-content/43f2d71f-52fd-4f32-87aa-0d842821e356.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'442e8c8a-f761-4bbf-92b9-31aa09669ba4', N'PRN0006', N'442e8c8a-f761-4bbf-92b9-31aa09669ba4.png', N'https://localhost:5001/app-content/442e8c8a-f761-4bbf-92b9-31aa09669ba4.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'4b5292dd-7c1e-44d8-b6b3-72ba68519934', N'PRN0027', N'4b5292dd-7c1e-44d8-b6b3-72ba68519934.png', N'https://localhost:5001/app-content/4b5292dd-7c1e-44d8-b6b3-72ba68519934.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'53739526-5ccb-4939-b23f-60ef57fa7443', N'PRN0001', N'53739526-5ccb-4939-b23f-60ef57fa7443.png', N'https://localhost:5001/app-content/53739526-5ccb-4939-b23f-60ef57fa7443.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'53a8888d-7ada-4b23-b4a7-3d32f9d60c54', N'PRN0007', N'53a8888d-7ada-4b23-b4a7-3d32f9d60c54.png', N'https://localhost:5001/app-content/53a8888d-7ada-4b23-b4a7-3d32f9d60c54.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'5a08ea5e-18a7-4c3a-9657-594518284d62', N'PRN0031', N'5a08ea5e-18a7-4c3a-9657-594518284d62.png', N'https://localhost:5001/app-content/5a08ea5e-18a7-4c3a-9657-594518284d62.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'5a52a065-002a-4b90-93c0-3a090bbe5972', N'PRN0009', N'5a52a065-002a-4b90-93c0-3a090bbe5972.png', N'https://localhost:5001/app-content/5a52a065-002a-4b90-93c0-3a090bbe5972.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'5d78b899-2733-488e-a739-13aa4cd10bad', N'PRN0003', N'5d78b899-2733-488e-a739-13aa4cd10bad.png', N'https://localhost:5001/app-content/5d78b899-2733-488e-a739-13aa4cd10bad.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'6385a11c-30a9-43e1-87f1-e28fc496abf6', N'PRN0023', N'6385a11c-30a9-43e1-87f1-e28fc496abf6.png', N'https://localhost:5001/app-content/6385a11c-30a9-43e1-87f1-e28fc496abf6.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'6d86d473-1436-4a5f-9b6c-64c4ca239882', N'PRN0022', N'6d86d473-1436-4a5f-9b6c-64c4ca239882.png', N'https://localhost:5001/app-content/6d86d473-1436-4a5f-9b6c-64c4ca239882.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'6f4a0160-368e-4b2f-84eb-fa844e1da546', N'PRN0005', N'6f4a0160-368e-4b2f-84eb-fa844e1da546.png', N'https://localhost:5001/app-content/6f4a0160-368e-4b2f-84eb-fa844e1da546.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'748115a8-b02f-4e7c-b233-53b99f63eab0', N'PRN0017', N'748115a8-b02f-4e7c-b233-53b99f63eab0.png', N'https://localhost:5001/app-content/748115a8-b02f-4e7c-b233-53b99f63eab0.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'7ea9cd86-4635-4b2f-ab28-9e1f0fd032ed', N'PRN0020', N'7ea9cd86-4635-4b2f-ab28-9e1f0fd032ed.png', N'https://localhost:5001/app-content/7ea9cd86-4635-4b2f-ab28-9e1f0fd032ed.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'8db58c9e-9ba8-4590-a15d-31c7d3b23a64', N'PRN0024', N'8db58c9e-9ba8-4590-a15d-31c7d3b23a64.png', N'https://localhost:5001/app-content/8db58c9e-9ba8-4590-a15d-31c7d3b23a64.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'9474d423-641d-4739-b57f-c7ebe3411317', N'PRN0030', N'9474d423-641d-4739-b57f-c7ebe3411317.png', N'https://localhost:5001/app-content/9474d423-641d-4739-b57f-c7ebe3411317.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'9a9b042b-8d2d-4e58-8695-a042a73333c3', N'PRN0008', N'9a9b042b-8d2d-4e58-8695-a042a73333c3.png', N'https://localhost:5001/app-content/9a9b042b-8d2d-4e58-8695-a042a73333c3.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'a7991296-2e25-4838-9f03-b2acf29e8085', N'PRN0029', N'a7991296-2e25-4838-9f03-b2acf29e8085.png', N'https://localhost:5001/app-content/a7991296-2e25-4838-9f03-b2acf29e8085.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'afe8a8f4-7296-4366-bcef-8cbc65ae332b', N'PRN0013', N'afe8a8f4-7296-4366-bcef-8cbc65ae332b.png', N'https://localhost:5001/app-content/afe8a8f4-7296-4366-bcef-8cbc65ae332b.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'bc87046b-193e-4703-8e3a-c54c46ce2903', N'PRN0021', N'bc87046b-193e-4703-8e3a-c54c46ce2903.png', N'https://localhost:5001/app-content/bc87046b-193e-4703-8e3a-c54c46ce2903.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'beeeac29-506f-4804-ae8d-ac4634705baf', N'PRN0012', N'beeeac29-506f-4804-ae8d-ac4634705baf.png', N'https://localhost:5001/app-content/beeeac29-506f-4804-ae8d-ac4634705baf.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'd365575a-b137-4f0b-82ad-e99c59be0801', N'PRN0025', N'd365575a-b137-4f0b-82ad-e99c59be0801.png', N'https://localhost:5001/app-content/d365575a-b137-4f0b-82ad-e99c59be0801.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'd7a081dd-6b82-4800-aa66-4e5db220e778', N'PRN0018', N'd7a081dd-6b82-4800-aa66-4e5db220e778.png', N'https://localhost:5001/app-content/d7a081dd-6b82-4800-aa66-4e5db220e778.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'ea53ec5d-7fea-48f8-b164-e34c7ab24e71', N'PRN0010', N'ea53ec5d-7fea-48f8-b164-e34c7ab24e71.png', N'https://localhost:5001/app-content/ea53ec5d-7fea-48f8-b164-e34c7ab24e71.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'eb0636cf-ff2f-4f4d-9b48-2466b0b565fd', N'PRN0002', N'eb0636cf-ff2f-4f4d-9b48-2466b0b565fd.png', N'https://localhost:5001/app-content/eb0636cf-ff2f-4f4d-9b48-2466b0b565fd.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'f579a85b-680a-498f-859f-eda5039bd5e4', N'PRN0028', N'f579a85b-680a-498f-859f-eda5039bd5e4.png', N'https://localhost:5001/app-content/f579a85b-680a-498f-859f-eda5039bd5e4.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'f71a2eb9-a22a-43d5-bf89-60fa93544721', N'PRN0016', N'f71a2eb9-a22a-43d5-bf89-60fa93544721.png', N'https://localhost:5001/app-content/f71a2eb9-a22a-43d5-bf89-60fa93544721.png', 1)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImagePath], [FullPath], [IsThumbnail]) VALUES (N'fcffa3dc-d231-4ae9-a4fd-0ea139275eca', N'PRN0014', N'fcffa3dc-d231-4ae9-a4fd-0ea139275eca.png', N'https://localhost:5001/app-content/fcffa3dc-d231-4ae9-a4fd-0ea139275eca.png', 1)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0001', N'Macbook Pro 2020', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 1340, CAST(22500000.00 AS Decimal(18, 2)), CAST(21500000.00 AS Decimal(18, 2)), 0, N'bedf848d-f7d0-433f-98f1-2731067335af', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0002', N'Macbook Air 2020', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 1340, CAST(20500000.00 AS Decimal(18, 2)), CAST(20000000.00 AS Decimal(18, 2)), 0, N'bedf848d-f7d0-433f-98f1-2731067335af', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0003', N'iMac 2017', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(32500000.00 AS Decimal(18, 2)), CAST(32000000.00 AS Decimal(18, 2)), 0, N'bedf848d-f7d0-433f-98f1-2731067335af', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0004', N'iMac 2020', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 1234, CAST(42000000.00 AS Decimal(18, 2)), CAST(41500000.00 AS Decimal(18, 2)), 0, N'bedf848d-f7d0-433f-98f1-2731067335af', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0005', N'Nitro 5', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2040, CAST(22500000.00 AS Decimal(18, 2)), CAST(22000000.00 AS Decimal(18, 2)), 0, N'7d6affea-fde6-4136-a532-0909d68bc802', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0006', N'Predator Triton', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2100, CAST(52500000.00 AS Decimal(18, 2)), CAST(510000000.00 AS Decimal(18, 2)), 0, N'7d6affea-fde6-4136-a532-0909d68bc802', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0007', N'Aspire 3', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2300, CAST(9350000.00 AS Decimal(18, 2)), CAST(9000000.00 AS Decimal(18, 2)), 0, N'7d6affea-fde6-4136-a532-0909d68bc802', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0008', N'Swift 3', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2300, CAST(12350000.00 AS Decimal(18, 2)), CAST(12000000.00 AS Decimal(18, 2)), 0, N'7d6affea-fde6-4136-a532-0909d68bc802', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0009', N'Vivobook', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2695, CAST(12500000.00 AS Decimal(18, 2)), CAST(12000000.00 AS Decimal(18, 2)), 0, N'f1756f5a-bf11-4008-943a-9aa69f40e478', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0010', N'Zenbook', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2700, CAST(22500000.00 AS Decimal(18, 2)), CAST(22000000.00 AS Decimal(18, 2)), 0, N'f1756f5a-bf11-4008-943a-9aa69f40e478', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0011', N'ROG Strix', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(32500000.00 AS Decimal(18, 2)), CAST(32000000.00 AS Decimal(18, 2)), 0, N'f1756f5a-bf11-4008-943a-9aa69f40e478', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0012', N'Thinkpad X250', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(12500000.00 AS Decimal(18, 2)), CAST(12000000.00 AS Decimal(18, 2)), 0, N'01e4179b-1042-489c-8470-984badfd6433', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0013', N'Thinkpad X260', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(15500000.00 AS Decimal(18, 2)), CAST(15000000.00 AS Decimal(18, 2)), 0, N'01e4179b-1042-489c-8470-984badfd6433', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0014', N'Thinkpad X270', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(18500000.00 AS Decimal(18, 2)), CAST(18000000.00 AS Decimal(18, 2)), 0, N'01e4179b-1042-489c-8470-984badfd6433', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0015', N'Thinkpad X280', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(21500000.00 AS Decimal(18, 2)), CAST(20500000.00 AS Decimal(18, 2)), 0, N'01e4179b-1042-489c-8470-984badfd6433', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0016', N'Thinkpad X290', NULL, N'3db32842-3ed5-458b-ad96-a113d73775ee', NULL, 2000, CAST(27500000.00 AS Decimal(18, 2)), CAST(27000000.00 AS Decimal(18, 2)), 0, N'01e4179b-1042-489c-8470-984badfd6433', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0017', N'Canon LBP 290', NULL, N'dabde5d3-3311-4836-8b37-18df01b9a371', NULL, 2000, CAST(2500000.00 AS Decimal(18, 2)), CAST(2000000.00 AS Decimal(18, 2)), 0, N'af7c139a-02d4-4f24-99c6-d49173de2b19', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0018', N'Canon LBP 290', NULL, N'dabde5d3-3311-4836-8b37-18df01b9a371', NULL, 2000, CAST(2500000.00 AS Decimal(18, 2)), CAST(2000000.00 AS Decimal(18, 2)), 0, N'af7c139a-02d4-4f24-99c6-d49173de2b19', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0019', N'Canon LBP 310', NULL, N'dabde5d3-3311-4836-8b37-18df01b9a371', NULL, 2000, CAST(2800000.00 AS Decimal(18, 2)), CAST(2750000.00 AS Decimal(18, 2)), 0, N'af7c139a-02d4-4f24-99c6-d49173de2b19', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0020', N'Canon LBP X320', NULL, N'dabde5d3-3311-4836-8b37-18df01b9a371', NULL, 2000, CAST(3500000.00 AS Decimal(18, 2)), CAST(3000000.00 AS Decimal(18, 2)), 0, N'af7c139a-02d4-4f24-99c6-d49173de2b19', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0021', N'Canon LBP Z320', NULL, N'dabde5d3-3311-4836-8b37-18df01b9a371', NULL, 2000, CAST(4500000.00 AS Decimal(18, 2)), CAST(4250000.00 AS Decimal(18, 2)), 0, N'af7c139a-02d4-4f24-99c6-d49173de2b19', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0022', N'G102', NULL, N'9a3f3ba5-76db-434a-acae-18fc90f1e1d6', NULL, 2000, CAST(500000.00 AS Decimal(18, 2)), CAST(450000.00 AS Decimal(18, 2)), 0, N'8e64301e-0a6c-48f5-b004-c5c0ffa155f5', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0023', N'G103', NULL, N'9a3f3ba5-76db-434a-acae-18fc90f1e1d6', NULL, 2000, CAST(540000.00 AS Decimal(18, 2)), CAST(535000.00 AS Decimal(18, 2)), 0, N'8e64301e-0a6c-48f5-b004-c5c0ffa155f5', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0024', N'G104', NULL, N'9a3f3ba5-76db-434a-acae-18fc90f1e1d6', NULL, 2000, CAST(580000.00 AS Decimal(18, 2)), CAST(5500000.00 AS Decimal(18, 2)), 0, N'8e64301e-0a6c-48f5-b004-c5c0ffa155f5', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0025', N'G105', NULL, N'9a3f3ba5-76db-434a-acae-18fc90f1e1d6', NULL, 2000, CAST(600000.00 AS Decimal(18, 2)), CAST(580000.00 AS Decimal(18, 2)), 0, N'8e64301e-0a6c-48f5-b004-c5c0ffa155f5', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0026', N'G106', NULL, N'9a3f3ba5-76db-434a-acae-18fc90f1e1d6', NULL, 2000, CAST(630000.00 AS Decimal(18, 2)), CAST(600000.00 AS Decimal(18, 2)), 0, N'8e64301e-0a6c-48f5-b004-c5c0ffa155f5', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0027', N'Kraken Pro V1', NULL, N'2fac847b-9fa2-4e68-803f-9bc331fe5a02', NULL, 2300, CAST(2500000.00 AS Decimal(18, 2)), CAST(2450000.00 AS Decimal(18, 2)), 0, N'992583af-900b-4318-93d5-008326458c4d', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0028', N'Kraken Pro V2', NULL, N'2fac847b-9fa2-4e68-803f-9bc331fe5a02', NULL, 2000, CAST(3500000.00 AS Decimal(18, 2)), CAST(3450000.00 AS Decimal(18, 2)), 0, N'992583af-900b-4318-93d5-008326458c4d', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0029', N'Kraken Pro V3', NULL, N'2fac847b-9fa2-4e68-803f-9bc331fe5a02', NULL, 2000, CAST(4500000.00 AS Decimal(18, 2)), CAST(4450000.00 AS Decimal(18, 2)), 0, N'992583af-900b-4318-93d5-008326458c4d', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0030', N'Kraken Pro V4', NULL, N'2fac847b-9fa2-4e68-803f-9bc331fe5a02', NULL, 2000, CAST(42500000.00 AS Decimal(18, 2)), CAST(4150000.00 AS Decimal(18, 2)), 0, N'992583af-900b-4318-93d5-008326458c4d', 1, 36)
INSERT [dbo].[Products] ([Id], [Name], [Information], [CategoryId], [Description], [Views], [RetailPrice], [WholesalePrices], [IsDelete], [BrandId], [StarScore], [WarrantyPeriod]) VALUES (N'PRN0031', N'Hammerhead', NULL, N'2fac847b-9fa2-4e68-803f-9bc331fe5a02', NULL, 2000, CAST(6500000.00 AS Decimal(18, 2)), CAST(6450000.00 AS Decimal(18, 2)), 0, N'992583af-900b-4318-93d5-008326458c4d', 1, 36)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'03d117de-96a2-4f65-8d46-ef7e25e10a69', N'PON0003', N'PRN0003', 100, CAST(30000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'2435d63d-73a7-4f14-80af-e282386982c6', N'PON0007', N'PRN0007', 100, CAST(9000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'33b88cf1-6ce0-4ffe-bc08-bf5d2caf97dc', N'PON0002', N'PRN0002', 50, CAST(22500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'3d4684a8-dcfb-4a43-8fc9-5ea256134bd8', N'PON0001', N'PRN0001', 100, CAST(22500000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'9b9b8b56-1f31-488f-b9e4-881828edc4e3', N'PON0006', N'PRN0006', 10, CAST(52000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'9cb9cd0f-bd17-427d-88d4-dcf2b8f3b9b9', N'PON0010', N'PRN0010', 10, CAST(22000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'a86650db-bd73-4e0e-84ff-90d1ace73627', N'PON0009', N'PRN0009', 10, CAST(12000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'ab179c4e-d5d1-45d6-bbcf-d36403cdfd7b', N'PON0004', N'PRN0004', 10, CAST(40000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'd2a0a5c3-bbdf-43b4-9f61-867c6a426427', N'PON0005', N'PRN0005', 100, CAST(22000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'e3ff3913-0c7c-405a-8dbc-8f0b780fd25d', N'PON0008', N'PRN0008', 10, CAST(12000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrderDetails] ([Id], [PurchaseOrderId], [ProductId], [Quantity], [UnitPrice], [CostName]) VALUES (N'e6ab6df8-cca2-4317-aefe-4a23b88586a3', N'PON0011', N'PRN0011', 10, CAST(32000000.00 AS Decimal(18, 2)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0001', NULL, N'SUN0001', CAST(N'2020-09-17T07:06:02.7620867' AS DateTime2), CAST(N'2020-09-17T07:06:02.7621226' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:06:02.8115419' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0002', NULL, N'SUN0002', CAST(N'2020-09-17T07:06:02.7620867' AS DateTime2), CAST(N'2020-09-17T07:06:02.7621226' AS DateTime2), N'43972588-ea79-4bf0-8ed7-7e9ef42170a7', CAST(N'2020-09-17T07:06:02.8116224' AS DateTime2), N'6187b25a-957c-4690-ba99-f64499119f35', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0003', NULL, N'SUN0003', CAST(N'2020-09-17T07:29:28.8433333' AS DateTime2), CAST(N'2020-09-17T07:29:28.8433333' AS DateTime2), N'43972588-ea79-4bf0-8ed7-7e9ef42170a7', CAST(N'2020-09-17T07:29:28.8433333' AS DateTime2), N'6187b25a-957c-4690-ba99-f64499119f35', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0004', NULL, N'SUN0004', CAST(N'2020-09-17T07:29:28.8466667' AS DateTime2), CAST(N'2020-09-17T07:29:28.8466667' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:29:28.8466667' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0005', NULL, N'SUN0005', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0006', NULL, N'SUN0006', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0007', NULL, N'SUN0007', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'43972588-ea79-4bf0-8ed7-7e9ef42170a7', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'57fa4d1a-974a-4157-bd6c-287db184a51e', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0008', NULL, N'SUN0008', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'43972588-ea79-4bf0-8ed7-7e9ef42170a7', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'57fa4d1a-974a-4157-bd6c-287db184a51e', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0009', NULL, N'SUN0009', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0010', NULL, N'SUN0010', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[PurchaseOrders] ([Id], [Note], [SupplierId], [DateCreated], [PurchaseDate], [OrderStatusId], [DeliveryDate], [PaymentStatusId], [IsDelete], [DiscountTypeId], [DiscountValue], [DiscountDescription]) VALUES (N'PON0011', NULL, N'SUN0011', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'80b1a453-82a4-47ed-964e-1b69af87a1e1', CAST(N'2020-09-17T07:29:28.8500000' AS DateTime2), N'646233ce-0eb0-4ed1-a5c6-8e16e1376393', 0, NULL, CAST(0 AS Decimal(18, 0)), NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0001', N'ODN0001', CAST(22500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:06:02.8127456' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0002', N'ODN0002', CAST(10500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:06:02.8128049' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0003', N'ODN0003', CAST(65000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8533333' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0004', N'ODN0004', CAST(42000000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0005', N'ODN0005', CAST(22500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0006', N'ODN0006', CAST(52500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0007', N'ODN0007', CAST(9350000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0008', N'ODN0008', CAST(12350000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0009', N'ODN0009', CAST(12500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0010', N'ODN0010', CAST(22500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8566667' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[ReceiptVouchers] ([Id], [OrderId], [Received], [ReceivedDate], [PaymentMethodId], [IsDelete], [Description], [SupplierId], [CustomerId]) VALUES (N'RVN0011', N'ODN0011', CAST(32500000.00 AS Decimal(18, 2)), CAST(N'2020-09-17T07:29:28.8600000' AS DateTime2), N'a2b931dd-c5be-47c5-a134-f9f3474cf630', 0, NULL, NULL, NULL)
INSERT [dbo].[StockActions] ([Id], [Name]) VALUES (N'0a12a679-0952-414f-a1e6-990b34f1be07', N'Nhập hàng vào kho')
INSERT [dbo].[StockActions] ([Id], [Name]) VALUES (N'1be88fef-0b15-4429-9012-9771a6e849f1', N'Xuất kho giao hàng cho khách/shipper')
INSERT [dbo].[StockActions] ([Id], [Name]) VALUES (N'a8ef7eae-3fad-4711-a4f0-8b5b7e5084af', N'Cân bằng kho')
INSERT [dbo].[StockActions] ([Id], [Name]) VALUES (N'd6f2e2be-d9d4-40bf-b872-1c5d747466c9', N'Khởi tạo')
INSERT [dbo].[StockHistories] ([Id], [ProductId], [RecordDate], [EmployeeId], [StockActionId], [ChangeQuantity], [PurchaseOrderDetailId], [OrderDetailId]) VALUES (N'332469da-fa27-4d84-8bf8-a1da22e68d18', N'PRN0002', CAST(N'2020-09-17T07:06:02.8131559' AS DateTime2), N'EPN0001', N'1be88fef-0b15-4429-9012-9771a6e849f1', -1, NULL, N'27f6e5e9-a08c-4470-849b-20b9bc3cef39')
INSERT [dbo].[StockHistories] ([Id], [ProductId], [RecordDate], [EmployeeId], [StockActionId], [ChangeQuantity], [PurchaseOrderDetailId], [OrderDetailId]) VALUES (N'849765e2-31a4-486b-8da4-cb8521c3f370', N'PRN0001', CAST(N'2020-09-17T07:06:02.8131076' AS DateTime2), N'EPN0001', N'1be88fef-0b15-4429-9012-9771a6e849f1', -1, NULL, N'7c2139ae-ee0b-4e6a-9c48-32428fc4c032')
INSERT [dbo].[StockHistories] ([Id], [ProductId], [RecordDate], [EmployeeId], [StockActionId], [ChangeQuantity], [PurchaseOrderDetailId], [OrderDetailId]) VALUES (N'b9b095eb-0974-4aac-bee4-5358c2401b99', N'PRN0001', CAST(N'2020-09-17T07:06:02.8129085' AS DateTime2), N'EPN0001', N'd6f2e2be-d9d4-40bf-b872-1c5d747466c9', 100, N'3d4684a8-dcfb-4a43-8fc9-5ea256134bd8', NULL)
INSERT [dbo].[StockHistories] ([Id], [ProductId], [RecordDate], [EmployeeId], [StockActionId], [ChangeQuantity], [PurchaseOrderDetailId], [OrderDetailId]) VALUES (N'deef8666-a71c-4441-be9d-315e99353a8d', N'PRN0002', CAST(N'2020-09-17T07:06:02.8131025' AS DateTime2), N'EPN0001', N'd6f2e2be-d9d4-40bf-b872-1c5d747466c9', 50, N'33b88cf1-6ce0-4ffe-bc08-bf5d2caf97dc', NULL)
INSERT [dbo].[Stocks] ([ProductId], [AbleToSale], [Inventory]) VALUES (N'PRN0001', 99, 99)
INSERT [dbo].[Stocks] ([ProductId], [AbleToSale], [Inventory]) VALUES (N'PRN0002', 49, 49)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0001', N'Công ty TNHH ABC', N'Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', N'1234567890', 0, N'contyabc@gmail.com', N'1234567890', N'EPN0001', N'abc.com.vn', NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0002', N'Công ty TNHH DEF', N'Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', N'1234567890', 0, N'contyabc@gmail.com', N'1234567890', N'EPN0001', N'abc.com.vn', NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0003', N'Công ty TNHH A', N'Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0004', N'Công ty TNHH B', N'Số 98, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0005', N'Công ty TNHH C', N'Số 97, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0006', N'Công ty TNHH D', N'Số 96, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0007', N'Công ty TNHH E', N'Số 95, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0008', N'Công ty TNHH F', N'Số 94, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0009', N'Công ty TNHH G', N'Số 93, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0010', N'Công ty TNHH H', N'Số 92, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0011', N'Công ty TNHH J', N'Số 91, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0012', N'Công ty TNHH K', N'Số 90, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Suppliers] ([Id], [Name], [Address], [PhoneNumber], [IsDelete], [Email], [Fax], [EmployeeId], [Website], [Description]) VALUES (N'SUN0013', N'Công ty TNHH L', N'Số 89, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng', NULL, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Transporters] ([Id], [Name], [PhoneNumber]) VALUES (N'be2ba488-7bf5-491d-ac72-15d3d4c50c05', N'Giao hàng nhanh', N'1234567890')
/****** Object:  Index [IX_AppRoles_AppUserId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_AppRoles_AppUserId] ON [dbo].[AppRoles]
(
	[AppUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Carts_ProductId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Carts_ProductId] ON [dbo].[Carts]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Customers_CustomerTypeId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Customers_CustomerTypeId] ON [dbo].[Customers]
(
	[CustomerTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Customers_UserId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Customers_UserId] ON [dbo].[Customers]
(
	[UserId] ASC
)
WHERE ([UserId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Employees_UserId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Employees_UserId] ON [dbo].[Employees]
(
	[UserId] ASC
)
WHERE ([UserId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_OrderDetails_OrderId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_OrderDetails_OrderId] ON [dbo].[OrderDetails]
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_OrderDetails_ProductId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_OrderDetails_ProductId] ON [dbo].[OrderDetails]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Orders_CustomerId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Orders_CustomerId] ON [dbo].[Orders]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Orders_DiscountTypeId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Orders_DiscountTypeId] ON [dbo].[Orders]
(
	[DiscountTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Orders_OrderStatusId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Orders_OrderStatusId] ON [dbo].[Orders]
(
	[OrderStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Orders_PaymentStatusId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Orders_PaymentStatusId] ON [dbo].[Orders]
(
	[PaymentStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PaymentVouchers_CustomerId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PaymentVouchers_CustomerId] ON [dbo].[PaymentVouchers]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PaymentVouchers_PaymentMethodId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PaymentVouchers_PaymentMethodId] ON [dbo].[PaymentVouchers]
(
	[PaymentMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PaymentVouchers_PurchaseOrderId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PaymentVouchers_PurchaseOrderId] ON [dbo].[PaymentVouchers]
(
	[PurchaseOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PaymentVouchers_SupplierId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PaymentVouchers_SupplierId] ON [dbo].[PaymentVouchers]
(
	[SupplierId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ProductImages_ProductId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductImages_ProductId] ON [dbo].[ProductImages]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ProductReviewReplies_ProductReviewId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductReviewReplies_ProductReviewId] ON [dbo].[ProductReviewReplies]
(
	[ProductReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProductReviewReplies_UserId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductReviewReplies_UserId] ON [dbo].[ProductReviewReplies]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ProductReviews_ProductId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductReviews_ProductId] ON [dbo].[ProductReviews]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProductReviews_UserId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ProductReviews_UserId] ON [dbo].[ProductReviews]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Products_BrandId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Products_BrandId] ON [dbo].[Products]
(
	[BrandId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Products_CategoryId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Products_CategoryId] ON [dbo].[Products]
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PurchaseOrderDetails_ProductId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PurchaseOrderDetails_ProductId] ON [dbo].[PurchaseOrderDetails]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PurchaseOrderDetails_PurchaseOrderId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PurchaseOrderDetails_PurchaseOrderId] ON [dbo].[PurchaseOrderDetails]
(
	[PurchaseOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PurchaseOrders_DiscountTypeId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PurchaseOrders_DiscountTypeId] ON [dbo].[PurchaseOrders]
(
	[DiscountTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PurchaseOrders_OrderStatusId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PurchaseOrders_OrderStatusId] ON [dbo].[PurchaseOrders]
(
	[OrderStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PurchaseOrders_PaymentStatusId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PurchaseOrders_PaymentStatusId] ON [dbo].[PurchaseOrders]
(
	[PaymentStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PurchaseOrders_SupplierId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_PurchaseOrders_SupplierId] ON [dbo].[PurchaseOrders]
(
	[SupplierId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ReceiptVouchers_CustomerId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ReceiptVouchers_CustomerId] ON [dbo].[ReceiptVouchers]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ReceiptVouchers_OrderId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ReceiptVouchers_OrderId] ON [dbo].[ReceiptVouchers]
(
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ReceiptVouchers_PaymentMethodId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ReceiptVouchers_PaymentMethodId] ON [dbo].[ReceiptVouchers]
(
	[PaymentMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ReceiptVouchers_SupplierId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ReceiptVouchers_SupplierId] ON [dbo].[ReceiptVouchers]
(
	[SupplierId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ShippingOrders_CustomerId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ShippingOrders_CustomerId] ON [dbo].[ShippingOrders]
(
	[CustomerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ShippingOrders_ShippingStatusId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ShippingOrders_ShippingStatusId] ON [dbo].[ShippingOrders]
(
	[ShippingStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ShippingOrders_TransporterId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_ShippingOrders_TransporterId] ON [dbo].[ShippingOrders]
(
	[TransporterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_StockHistories_EmployeeId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_StockHistories_EmployeeId] ON [dbo].[StockHistories]
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_StockHistories_OrderDetailId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_StockHistories_OrderDetailId] ON [dbo].[StockHistories]
(
	[OrderDetailId] ASC
)
WHERE ([OrderDetailId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_StockHistories_ProductId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_StockHistories_ProductId] ON [dbo].[StockHistories]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_StockHistories_PurchaseOrderDetailId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_StockHistories_PurchaseOrderDetailId] ON [dbo].[StockHistories]
(
	[PurchaseOrderDetailId] ASC
)
WHERE ([PurchaseOrderDetailId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_StockHistories_StockActionId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_StockHistories_StockActionId] ON [dbo].[StockHistories]
(
	[StockActionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Suppliers_EmployeeId]    Script Date: 9/17/2020 7:38:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Suppliers_EmployeeId] ON [dbo].[Suppliers]
(
	[EmployeeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppUsers] ADD  DEFAULT ('2020-09-17T07:06:02.7149179+07:00') FOR [DateCreated]
GO
ALTER TABLE [dbo].[Carts] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT ('1990-01-01T00:00:00.0000000') FOR [Dob]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (CONVERT([bit],(0))) FOR [Gender]
GO
ALTER TABLE [dbo].[Customers] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[CustomerTypes] ADD  DEFAULT ('2020-09-17T07:06:02.7244460+07:00') FOR [DateCreated]
GO
ALTER TABLE [dbo].[Employees] ADD  DEFAULT ('1990-01-01T00:00:00.0000000') FOR [Dob]
GO
ALTER TABLE [dbo].[Employees] ADD  DEFAULT (CONVERT([bit],(0))) FOR [Gender]
GO
ALTER TABLE [dbo].[Employees] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[OrderDetails] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT ('2020-09-17T07:06:02.7718124+07:00') FOR [DateCreated]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT ((0.0)) FOR [DiscountValue]
GO
ALTER TABLE [dbo].[PaymentVouchers] ADD  DEFAULT ('2020-09-17T07:06:02.7671490+07:00') FOR [PayDate]
GO
ALTER TABLE [dbo].[PaymentVouchers] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[ProductImages] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsThumbnail]
GO
ALTER TABLE [dbo].[ProductReviews] ADD  DEFAULT (CONVERT([tinyint],(1))) FOR [StarScore]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [Views]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0.0)) FOR [RetailPrice]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0.0)) FOR [WholesalePrices]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (CONVERT([tinyint],(1))) FOR [StarScore]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (CONVERT([tinyint],(0))) FOR [WarrantyPeriod]
GO
ALTER TABLE [dbo].[PurchaseOrderDetails] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[PurchaseOrders] ADD  DEFAULT ('2020-09-17T07:06:02.7620867+07:00') FOR [DateCreated]
GO
ALTER TABLE [dbo].[PurchaseOrders] ADD  DEFAULT ('2020-09-17T07:06:02.7621226+07:00') FOR [PurchaseDate]
GO
ALTER TABLE [dbo].[PurchaseOrders] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[PurchaseOrders] ADD  DEFAULT ((0.0)) FOR [DiscountValue]
GO
ALTER TABLE [dbo].[ReceiptVouchers] ADD  DEFAULT ((0.0)) FOR [Received]
GO
ALTER TABLE [dbo].[ReceiptVouchers] ADD  DEFAULT ('2020-09-17T07:06:02.7770581+07:00') FOR [ReceivedDate]
GO
ALTER TABLE [dbo].[ReceiptVouchers] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[ShippingOrders] ADD  DEFAULT ((0.0)) FOR [Fee]
GO
ALTER TABLE [dbo].[ShippingOrders] ADD  DEFAULT ('2020-09-17T07:06:02.7844756+07:00') FOR [DateCreated]
GO
ALTER TABLE [dbo].[StockHistories] ADD  DEFAULT ('2020-09-17T07:06:02.7803306+07:00') FOR [RecordDate]
GO
ALTER TABLE [dbo].[StockHistories] ADD  DEFAULT ((0)) FOR [ChangeQuantity]
GO
ALTER TABLE [dbo].[Stocks] ADD  DEFAULT ((0)) FOR [AbleToSale]
GO
ALTER TABLE [dbo].[Stocks] ADD  DEFAULT ((0)) FOR [Inventory]
GO
ALTER TABLE [dbo].[Suppliers] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDelete]
GO
ALTER TABLE [dbo].[AppRoles]  WITH CHECK ADD  CONSTRAINT [FK_AppRoles_AppUsers_AppUserId] FOREIGN KEY([AppUserId])
REFERENCES [dbo].[AppUsers] ([Id])
GO
ALTER TABLE [dbo].[AppRoles] CHECK CONSTRAINT [FK_AppRoles_AppUsers_AppUserId]
GO
ALTER TABLE [dbo].[Carts]  WITH CHECK ADD  CONSTRAINT [FK_Carts_AppUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Carts] CHECK CONSTRAINT [FK_Carts_AppUsers_UserId]
GO
ALTER TABLE [dbo].[Carts]  WITH CHECK ADD  CONSTRAINT [FK_Carts_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Carts] CHECK CONSTRAINT [FK_Carts_Products_ProductId]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_AppUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUsers] ([Id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FK_Customers_AppUsers_UserId]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_CustomerTypes_CustomerTypeId] FOREIGN KEY([CustomerTypeId])
REFERENCES [dbo].[CustomerTypes] ([Id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FK_Customers_CustomerTypes_CustomerTypeId]
GO
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_AppUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUsers] ([Id])
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_AppUsers_UserId]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Orders_OrderId] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Orders] ([Id])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Orders_OrderId]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Products_ProductId]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customers_CustomerId] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customers] ([Id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customers_CustomerId]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_DiscountTypes_DiscountTypeId] FOREIGN KEY([DiscountTypeId])
REFERENCES [dbo].[DiscountTypes] ([Id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_DiscountTypes_DiscountTypeId]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_OrderStatuses_OrderStatusId] FOREIGN KEY([OrderStatusId])
REFERENCES [dbo].[OrderStatuses] ([Id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_OrderStatuses_OrderStatusId]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_PaymentStatuses_PaymentStatusId] FOREIGN KEY([PaymentStatusId])
REFERENCES [dbo].[PaymentStatuses] ([Id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_PaymentStatuses_PaymentStatusId]
GO
ALTER TABLE [dbo].[PaymentVouchers]  WITH CHECK ADD  CONSTRAINT [FK_PaymentVouchers_Customers_CustomerId] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customers] ([Id])
GO
ALTER TABLE [dbo].[PaymentVouchers] CHECK CONSTRAINT [FK_PaymentVouchers_Customers_CustomerId]
GO
ALTER TABLE [dbo].[PaymentVouchers]  WITH CHECK ADD  CONSTRAINT [FK_PaymentVouchers_PaymentMethods_PaymentMethodId] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[PaymentMethods] ([Id])
GO
ALTER TABLE [dbo].[PaymentVouchers] CHECK CONSTRAINT [FK_PaymentVouchers_PaymentMethods_PaymentMethodId]
GO
ALTER TABLE [dbo].[PaymentVouchers]  WITH CHECK ADD  CONSTRAINT [FK_PaymentVouchers_PurchaseOrders_PurchaseOrderId] FOREIGN KEY([PurchaseOrderId])
REFERENCES [dbo].[PurchaseOrders] ([Id])
GO
ALTER TABLE [dbo].[PaymentVouchers] CHECK CONSTRAINT [FK_PaymentVouchers_PurchaseOrders_PurchaseOrderId]
GO
ALTER TABLE [dbo].[PaymentVouchers]  WITH CHECK ADD  CONSTRAINT [FK_PaymentVouchers_Suppliers_SupplierId] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Suppliers] ([Id])
GO
ALTER TABLE [dbo].[PaymentVouchers] CHECK CONSTRAINT [FK_PaymentVouchers_Suppliers_SupplierId]
GO
ALTER TABLE [dbo].[ProductImages]  WITH CHECK ADD  CONSTRAINT [FK_ProductImages_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductImages] CHECK CONSTRAINT [FK_ProductImages_Products_ProductId]
GO
ALTER TABLE [dbo].[ProductReviewReplies]  WITH CHECK ADD  CONSTRAINT [FK_ProductReviewReplies_AppUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUsers] ([Id])
GO
ALTER TABLE [dbo].[ProductReviewReplies] CHECK CONSTRAINT [FK_ProductReviewReplies_AppUsers_UserId]
GO
ALTER TABLE [dbo].[ProductReviewReplies]  WITH CHECK ADD  CONSTRAINT [FK_ProductReviewReplies_ProductReviews_ProductReviewId] FOREIGN KEY([ProductReviewId])
REFERENCES [dbo].[ProductReviews] ([Id])
GO
ALTER TABLE [dbo].[ProductReviewReplies] CHECK CONSTRAINT [FK_ProductReviewReplies_ProductReviews_ProductReviewId]
GO
ALTER TABLE [dbo].[ProductReviews]  WITH CHECK ADD  CONSTRAINT [FK_ProductReviews_AppUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AppUsers] ([Id])
GO
ALTER TABLE [dbo].[ProductReviews] CHECK CONSTRAINT [FK_ProductReviews_AppUsers_UserId]
GO
ALTER TABLE [dbo].[ProductReviews]  WITH CHECK ADD  CONSTRAINT [FK_ProductReviews_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductReviews] CHECK CONSTRAINT [FK_ProductReviews_Products_ProductId]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Brands_BrandId] FOREIGN KEY([BrandId])
REFERENCES [dbo].[Brands] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Brands_BrandId]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories_CategoryId] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Categories_CategoryId]
GO
ALTER TABLE [dbo].[PurchaseOrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrderDetails_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[PurchaseOrderDetails] CHECK CONSTRAINT [FK_PurchaseOrderDetails_Products_ProductId]
GO
ALTER TABLE [dbo].[PurchaseOrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrderDetails_PurchaseOrders_PurchaseOrderId] FOREIGN KEY([PurchaseOrderId])
REFERENCES [dbo].[PurchaseOrders] ([Id])
GO
ALTER TABLE [dbo].[PurchaseOrderDetails] CHECK CONSTRAINT [FK_PurchaseOrderDetails_PurchaseOrders_PurchaseOrderId]
GO
ALTER TABLE [dbo].[PurchaseOrders]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrders_DiscountTypes_DiscountTypeId] FOREIGN KEY([DiscountTypeId])
REFERENCES [dbo].[DiscountTypes] ([Id])
GO
ALTER TABLE [dbo].[PurchaseOrders] CHECK CONSTRAINT [FK_PurchaseOrders_DiscountTypes_DiscountTypeId]
GO
ALTER TABLE [dbo].[PurchaseOrders]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrders_OrderStatuses_OrderStatusId] FOREIGN KEY([OrderStatusId])
REFERENCES [dbo].[OrderStatuses] ([Id])
GO
ALTER TABLE [dbo].[PurchaseOrders] CHECK CONSTRAINT [FK_PurchaseOrders_OrderStatuses_OrderStatusId]
GO
ALTER TABLE [dbo].[PurchaseOrders]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrders_PaymentStatuses_PaymentStatusId] FOREIGN KEY([PaymentStatusId])
REFERENCES [dbo].[PaymentStatuses] ([Id])
GO
ALTER TABLE [dbo].[PurchaseOrders] CHECK CONSTRAINT [FK_PurchaseOrders_PaymentStatuses_PaymentStatusId]
GO
ALTER TABLE [dbo].[PurchaseOrders]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrders_Suppliers_SupplierId] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Suppliers] ([Id])
GO
ALTER TABLE [dbo].[PurchaseOrders] CHECK CONSTRAINT [FK_PurchaseOrders_Suppliers_SupplierId]
GO
ALTER TABLE [dbo].[ReceiptVouchers]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptVouchers_Customers_CustomerId] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customers] ([Id])
GO
ALTER TABLE [dbo].[ReceiptVouchers] CHECK CONSTRAINT [FK_ReceiptVouchers_Customers_CustomerId]
GO
ALTER TABLE [dbo].[ReceiptVouchers]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptVouchers_Orders_OrderId] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Orders] ([Id])
GO
ALTER TABLE [dbo].[ReceiptVouchers] CHECK CONSTRAINT [FK_ReceiptVouchers_Orders_OrderId]
GO
ALTER TABLE [dbo].[ReceiptVouchers]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptVouchers_PaymentMethods_PaymentMethodId] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[PaymentMethods] ([Id])
GO
ALTER TABLE [dbo].[ReceiptVouchers] CHECK CONSTRAINT [FK_ReceiptVouchers_PaymentMethods_PaymentMethodId]
GO
ALTER TABLE [dbo].[ReceiptVouchers]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptVouchers_Suppliers_SupplierId] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Suppliers] ([Id])
GO
ALTER TABLE [dbo].[ReceiptVouchers] CHECK CONSTRAINT [FK_ReceiptVouchers_Suppliers_SupplierId]
GO
ALTER TABLE [dbo].[ShippingOrders]  WITH CHECK ADD  CONSTRAINT [FK_ShippingOrders_Customers_CustomerId] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customers] ([Id])
GO
ALTER TABLE [dbo].[ShippingOrders] CHECK CONSTRAINT [FK_ShippingOrders_Customers_CustomerId]
GO
ALTER TABLE [dbo].[ShippingOrders]  WITH CHECK ADD  CONSTRAINT [FK_ShippingOrders_Orders_OrderId] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Orders] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ShippingOrders] CHECK CONSTRAINT [FK_ShippingOrders_Orders_OrderId]
GO
ALTER TABLE [dbo].[ShippingOrders]  WITH CHECK ADD  CONSTRAINT [FK_ShippingOrders_ShippingStatus_ShippingStatusId] FOREIGN KEY([ShippingStatusId])
REFERENCES [dbo].[ShippingStatus] ([Id])
GO
ALTER TABLE [dbo].[ShippingOrders] CHECK CONSTRAINT [FK_ShippingOrders_ShippingStatus_ShippingStatusId]
GO
ALTER TABLE [dbo].[ShippingOrders]  WITH CHECK ADD  CONSTRAINT [FK_ShippingOrders_Transporters_TransporterId] FOREIGN KEY([TransporterId])
REFERENCES [dbo].[Transporters] ([Id])
GO
ALTER TABLE [dbo].[ShippingOrders] CHECK CONSTRAINT [FK_ShippingOrders_Transporters_TransporterId]
GO
ALTER TABLE [dbo].[StockHistories]  WITH CHECK ADD  CONSTRAINT [FK_StockHistories_Employees_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[StockHistories] CHECK CONSTRAINT [FK_StockHistories_Employees_EmployeeId]
GO
ALTER TABLE [dbo].[StockHistories]  WITH CHECK ADD  CONSTRAINT [FK_StockHistories_OrderDetails_OrderDetailId] FOREIGN KEY([OrderDetailId])
REFERENCES [dbo].[OrderDetails] ([Id])
GO
ALTER TABLE [dbo].[StockHistories] CHECK CONSTRAINT [FK_StockHistories_OrderDetails_OrderDetailId]
GO
ALTER TABLE [dbo].[StockHistories]  WITH CHECK ADD  CONSTRAINT [FK_StockHistories_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[StockHistories] CHECK CONSTRAINT [FK_StockHistories_Products_ProductId]
GO
ALTER TABLE [dbo].[StockHistories]  WITH CHECK ADD  CONSTRAINT [FK_StockHistories_PurchaseOrderDetails_PurchaseOrderDetailId] FOREIGN KEY([PurchaseOrderDetailId])
REFERENCES [dbo].[PurchaseOrderDetails] ([Id])
GO
ALTER TABLE [dbo].[StockHistories] CHECK CONSTRAINT [FK_StockHistories_PurchaseOrderDetails_PurchaseOrderDetailId]
GO
ALTER TABLE [dbo].[StockHistories]  WITH CHECK ADD  CONSTRAINT [FK_StockHistories_StockActions_StockActionId] FOREIGN KEY([StockActionId])
REFERENCES [dbo].[StockActions] ([Id])
GO
ALTER TABLE [dbo].[StockHistories] CHECK CONSTRAINT [FK_StockHistories_StockActions_StockActionId]
GO
ALTER TABLE [dbo].[Stocks]  WITH CHECK ADD  CONSTRAINT [FK_Stocks_Products_ProductId] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Stocks] CHECK CONSTRAINT [FK_Stocks_Products_ProductId]
GO
ALTER TABLE [dbo].[Suppliers]  WITH CHECK ADD  CONSTRAINT [FK_Suppliers_Employees_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[Employees] ([Id])
GO
ALTER TABLE [dbo].[Suppliers] CHECK CONSTRAINT [FK_Suppliers_Employees_EmployeeId]
GO
/****** Object:  StoredProcedure [dbo].[prGetAccountDetail]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetAccountDetail]
(@userId uniqueidentifier)
as
begin
	select AppUsers.Id,UserName,Email,PhoneNumber,ISNULL(Customers.Address,Employees.Address) as [Address],
	ISNULL(Customers.Gender,Employees.Gender) as Gender,
	ISNULL(Customers.FullName,Employees.FullName) as FullName from AppUsers
	left join Customers on Customers.UserId=AppUsers.Id
	left join Employees on Employees.UserId=AppUsers.Id
	where AppUsers.Id=@userId
end;

--Lấy quyền mà tài khoản không thuộc về
GO
/****** Object:  StoredProcedure [dbo].[prGetAccountNotInRoles]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetAccountNotInRoles]
(@userId uniqueidentifier)
as
begin
	select AppRoles.Id,AppRoles.Description as Name
	from AppRoles
	cross join AppUserRoles 
	cross join AppUsers
	where AppUsers.Id=@userId and AppRoles.Id not in 
	(select RoleId from AppUserRoles where UserId=@userId)
	group by AppRoles.Id,AppRoles.Description
end;

--Lấy quyền mà tài khoản thuộc về
GO
/****** Object:  StoredProcedure [dbo].[prGetAccountRoles]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetAccountRoles]
(@userId uniqueidentifier)
as
begin
	select AppRoles.Id,AppRoles.Description as Name
	from AppUsers
	inner join AppUserRoles on AppUserRoles.UserId=AppUsers.Id
	inner join AppRoles on AppRoles.Id=AppUserRoles.RoleId
	where AppUsers.Id=@userId
end;


--Thêm dữ liệu
insert into Categories(Id,Name) VALUES('dabde5d3-3311-4836-8b37-18df01b9a371',N'Máy in')
insert into Categories(Id,Name) VALUES('45cb72fd-9ced-4de2-aae8-08dbb42fdbca',N'Bàn phím')
insert into Categories(Id,Name) VALUES('9a3f3ba5-76db-434a-acae-18fc90f1e1d6',N'Chuột')
insert into Categories(Id,Name) VALUES('2fac847b-9fa2-4e68-803f-9bc331fe5a02',N'Tai nghe')

insert into Brands(Id,Name) VALUES('7d6affea-fde6-4136-a532-0909d68bc802',N'Acer')
insert into Brands(Id,Name) VALUES('f1756f5a-bf11-4008-943a-9aa69f40e478',N'Asus')
insert into Brands(Id,Name) VALUES('01e4179b-1042-489c-8470-984badfd6433',N'Lenovo')
insert into Brands(Id,Name) VALUES('af7c139a-02d4-4f24-99c6-d49173de2b19',N'Canon')
insert into Brands(Id,Name) VALUES('992583af-900b-4318-93d5-008326458c4d',N'Razer')
insert into Brands(Id,Name) VALUES('8e64301e-0a6c-48f5-b004-c5c0ffa155f5',N'Logitech')


insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0003',N'iMac 2017','3db32842-3ed5-458b-ad96-a113d73775ee',2000,32500000,32000000,'bedf848d-f7d0-433f-98f1-2731067335af',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0004',N'iMac 2020','3db32842-3ed5-458b-ad96-a113d73775ee',1234,42000000,41500000,'bedf848d-f7d0-433f-98f1-2731067335af',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0005',N'Nitro 5','3db32842-3ed5-458b-ad96-a113d73775ee',2040,22500000,22000000,'7d6affea-fde6-4136-a532-0909d68bc802',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0006',N'Predator Triton','3db32842-3ed5-458b-ad96-a113d73775ee',2100,52500000,510000000,'7d6affea-fde6-4136-a532-0909d68bc802',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0007',N'Aspire 3','3db32842-3ed5-458b-ad96-a113d73775ee',2300,9350000,9000000,'7d6affea-fde6-4136-a532-0909d68bc802',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0008',N'Swift 3','3db32842-3ed5-458b-ad96-a113d73775ee',2300,12350000,12000000,'7d6affea-fde6-4136-a532-0909d68bc802',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0009',N'Vivobook','3db32842-3ed5-458b-ad96-a113d73775ee',2695,12500000,12000000,'f1756f5a-bf11-4008-943a-9aa69f40e478',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0010',N'Zenbook','3db32842-3ed5-458b-ad96-a113d73775ee',2700,22500000,22000000,'f1756f5a-bf11-4008-943a-9aa69f40e478',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0011',N'ROG Strix','3db32842-3ed5-458b-ad96-a113d73775ee',2000,32500000,32000000,'f1756f5a-bf11-4008-943a-9aa69f40e478',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0012',N'Thinkpad X250','3db32842-3ed5-458b-ad96-a113d73775ee',2000,12500000,12000000,'01e4179b-1042-489c-8470-984badfd6433',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0013',N'Thinkpad X260','3db32842-3ed5-458b-ad96-a113d73775ee',2000,15500000,15000000,'01e4179b-1042-489c-8470-984badfd6433',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0014',N'Thinkpad X270','3db32842-3ed5-458b-ad96-a113d73775ee',2000,18500000,18000000,'01e4179b-1042-489c-8470-984badfd6433',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0015',N'Thinkpad X280','3db32842-3ed5-458b-ad96-a113d73775ee',2000,21500000,20500000,'01e4179b-1042-489c-8470-984badfd6433',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0016',N'Thinkpad X290','3db32842-3ed5-458b-ad96-a113d73775ee',2000,27500000,27000000,'01e4179b-1042-489c-8470-984badfd6433',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0017',N'Canon LBP 290','dabde5d3-3311-4836-8b37-18df01b9a371',2000,2500000,2000000,'af7c139a-02d4-4f24-99c6-d49173de2b19',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0018',N'Canon LBP 290','dabde5d3-3311-4836-8b37-18df01b9a371',2000,2500000,2000000,'af7c139a-02d4-4f24-99c6-d49173de2b19',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0019',N'Canon LBP 310','dabde5d3-3311-4836-8b37-18df01b9a371',2000,2800000,2750000,'af7c139a-02d4-4f24-99c6-d49173de2b19',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0020',N'Canon LBP X320','dabde5d3-3311-4836-8b37-18df01b9a371',2000,3500000,3000000,'af7c139a-02d4-4f24-99c6-d49173de2b19',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0021',N'Canon LBP Z320','dabde5d3-3311-4836-8b37-18df01b9a371',2000,4500000,4250000,'af7c139a-02d4-4f24-99c6-d49173de2b19',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0022',N'G102','9a3f3ba5-76db-434a-acae-18fc90f1e1d6',2000,500000,450000,'8e64301e-0a6c-48f5-b004-c5c0ffa155f5',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0023',N'G103','9a3f3ba5-76db-434a-acae-18fc90f1e1d6',2000,540000,535000,'8e64301e-0a6c-48f5-b004-c5c0ffa155f5',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0024',N'G104','9a3f3ba5-76db-434a-acae-18fc90f1e1d6',2000,580000,5500000,'8e64301e-0a6c-48f5-b004-c5c0ffa155f5',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0025',N'G105','9a3f3ba5-76db-434a-acae-18fc90f1e1d6',2000,600000,580000,'8e64301e-0a6c-48f5-b004-c5c0ffa155f5',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0026',N'G106','9a3f3ba5-76db-434a-acae-18fc90f1e1d6',2000,630000,600000,'8e64301e-0a6c-48f5-b004-c5c0ffa155f5',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0027',N'Kraken Pro V1','2fac847b-9fa2-4e68-803f-9bc331fe5a02',2300,2500000,2450000,'992583af-900b-4318-93d5-008326458c4d',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0028',N'Kraken Pro V2','2fac847b-9fa2-4e68-803f-9bc331fe5a02',2000,3500000,3450000,'992583af-900b-4318-93d5-008326458c4d',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0029',N'Kraken Pro V3','2fac847b-9fa2-4e68-803f-9bc331fe5a02',2000,4500000,4450000,'992583af-900b-4318-93d5-008326458c4d',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0030',N'Kraken Pro V4','2fac847b-9fa2-4e68-803f-9bc331fe5a02',2000,42500000,4150000,'992583af-900b-4318-93d5-008326458c4d',1,36)

insert into Products(Id,Name,CategoryId,Views,RetailPrice,WholesalePrices,BrandId,StarScore,WarrantyPeriod)
VALUES('PRN0031',N'Hammerhead','2fac847b-9fa2-4e68-803f-9bc331fe5a02',2000,6500000,6450000,'992583af-900b-4318-93d5-008326458c4d',1,36)


insert into Suppliers(Id,Name,Address) VALUES('SUN0003',N'Công ty TNHH A',N'Số 99, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0004',N'Công ty TNHH B',N'Số 98, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0005',N'Công ty TNHH C',N'Số 97, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0006',N'Công ty TNHH D',N'Số 96, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0007',N'Công ty TNHH E',N'Số 95, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0008',N'Công ty TNHH F',N'Số 94, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0009',N'Công ty TNHH G',N'Số 93, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0010',N'Công ty TNHH H',N'Số 92, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0011',N'Công ty TNHH J',N'Số 91, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0012',N'Công ty TNHH K',N'Số 90, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')
insert into Suppliers(Id,Name,Address) VALUES('SUN0013',N'Công ty TNHH L',N'Số 89, Hải Triều, Quán Toan, Hồng Bàng, Hải Phòng')


insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0003','SUN0003',GETDATE(),GETDATE(),'43972588-ea79-4bf0-8ed7-7e9ef42170a7',GETDATE(),'6187b25a-957c-4690-ba99-f64499119f35',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('03d117de-96a2-4f65-8d46-ef7e25e10a69','PON0003','PRN0003',100,30000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0003','PON0003',2500000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0004','SUN0004',GETDATE(),GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1',GETDATE(),'646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('ab179c4e-d5d1-45d6-bbcf-d36403cdfd7b','PON0004','PRN0004',10,40000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0004','PON0004',400000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0005','SUN0005',GETDATE(),GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1',GETDATE(),'646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('d2a0a5c3-bbdf-43b4-9f61-867c6a426427','PON0005','PRN0005',100,22000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0005','PON0005',2200000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0006','SUN0006',GETDATE(),GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1',GETDATE(),'646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('9b9b8b56-1f31-488f-b9e4-881828edc4e3','PON0006','PRN0006',10,52000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0006','PON0006',520000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0007','SUN0007',GETDATE(),GETDATE(),'43972588-ea79-4bf0-8ed7-7e9ef42170a7',GETDATE(),'57fa4d1a-974a-4157-bd6c-287db184a51e',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('2435d63d-73a7-4f14-80af-e282386982c6','PON0007','PRN0007',100,9000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0007','PON0007',0,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0008','SUN0008',GETDATE(),GETDATE(),'43972588-ea79-4bf0-8ed7-7e9ef42170a7',GETDATE(),'57fa4d1a-974a-4157-bd6c-287db184a51e',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('e3ff3913-0c7c-405a-8dbc-8f0b780fd25d','PON0008','PRN0008',10,12000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0008','PON0008',0,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0009','SUN0009',GETDATE(),GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1',GETDATE(),'646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('a86650db-bd73-4e0e-84ff-90d1ace73627','PON0009','PRN0009',10,12000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0009','PON0009',120000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0010','SUN0010',GETDATE(),GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1',GETDATE(),'646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('9cb9cd0f-bd17-427d-88d4-dcf2b8f3b9b9','PON0010','PRN0010',10,22000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0010','PON0010',220000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into PurchaseOrders(Id,SupplierId,DateCreated,PurchaseDate,OrderStatusId,DeliveryDate,PaymentStatusId,DiscountValue)
VALUES ('PON0011','SUN0011',GETDATE(),GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1',GETDATE(),'646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into PurchaseOrderDetails(Id,PurchaseOrderId,ProductId,Quantity,UnitPrice) 
VALUES('e6ab6df8-cca2-4317-aefe-4a23b88586a3','PON0011','PRN0011',10,32000000)
insert into PaymentVouchers(Id,PurchaseOrderId,Paid,PayDate,PaymentMethodId)
VALUES('PVN0011','PON0011',320000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')


insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0003','CUS0001',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('e6f23913-f4b1-4908-9020-230ff2eee264','ODN0003','PRN0003',2,32500000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0003','ODN0003',65000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0004','CUS0001',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('bf5a1cca-3dd8-41a7-89b0-644cd2efc93f','ODN0004','PRN0004',1,42000000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0004','ODN0004',42000000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0005','CUS0001',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('d0663a4c-52a6-49e6-85f8-462fe06321ac','ODN0005','PRN0005',1,22500000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0005','ODN0005',22500000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0006','CUS0001',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('6006ec40-abb1-4563-aaa5-db40fc8da52c','ODN0006','PRN0006',1,52500000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0006','ODN0006',52500000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0007','CUS0001',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('2ae60321-773f-48f0-9c66-25179ca216a1','ODN0007','PRN0007',1,9350000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0007','ODN0007',9350000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0008','CUS0002',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('825050ee-defb-4cd2-b57f-bdb0c4a53d2a','ODN0008','PRN0008',1,12350000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0008','ODN0008',12350000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0009','CUS0002',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('bf690d30-9ec7-4e23-a9ce-57b3598e5354','ODN0009','PRN0009',1,12500000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0009','ODN0009',12500000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0010','CUS0002',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('c18ea094-de2d-4934-b970-2f3d20e24ee5','ODN0010','PRN0010',1,22500000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0010','ODN0010',22500000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')

insert into Orders(Id,CustomerId,DateCreated,OrderStatusId,PaymentStatusId,DiscountValue)
VALUES('ODN0011','CUS0002',GETDATE(),'80b1a453-82a4-47ed-964e-1b69af87a1e1','646233ce-0eb0-4ed1-a5c6-8e16e1376393',0.00)
insert into OrderDetails(Id,OrderId,ProductId,Quantity,UnitPrice)
VALUES('bb2da4f7-ff64-4b90-93b9-4cd77f7b7924','ODN0011','PRN0011',1,32500000)
insert into ReceiptVouchers(Id,OrderId,Received,ReceivedDate,PaymentMethodId)
VALUES('RVN0011','ODN0011',32500000,GETDATE(),'a2b931dd-c5be-47c5-a134-f9f3474cf630')
GO
/****** Object:  StoredProcedure [dbo].[prGetAccountsPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetAccountsPaging] 
(@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CTE as(
		select AppUsers.Id,UserName,Email,AppUsers.PhoneNumber,
		Customers.FullName as CustomerName,Employees.FullName as EmployeeName,AppUsers.DateCreated
		from AppUsers
		left join Employees on Employees.UserId=AppUsers.Id
		left join Customers on Customers.UserId=AppUsers.Id
	),Count_CTE as(
		select COUNT(*) as [TotalRecord] from Main_CTE
	)
	select * from Main_CTE, Count_CTE
	order by Main_CTE.UserName asc
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage row only
end;
-- Lấy thông tin chi tiết tài khoản
GO
/****** Object:  StoredProcedure [dbo].[prGetBestSellProducts]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetBestSellProducts]
as
begin
	select top 12 OrderDetails.ProductId as Id,Products.Name,Categories.Name as CategoryName,
	Products.RetailPrice,
	Products.StarScore, Brands.Name as BrandName,
	Products.Views,(select FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ImagePath
	from OrderDetails 
	inner join Orders on Orders.Id=OrderDetails.OrderId
	left join Products on Products.Id=OrderDetails.ProductId
	left join Categories on Categories.Id=Products.CategoryId
	left join Brands on Brands.Id=Products.BrandId
	WHERE MONTH(Orders.DateCreated)=MONTH(GETDATE()) and YEAR(Orders.DateCreated)=YEAR(GETDATE()) and Products.IsDelete=0
	group by OrderDetails.ProductId,Products.Name,Products.RetailPrice,Products.StarScore, Brands.Name,Products.Views,Products.Id,Categories.Name
	order by Sum(OrderDetails.Quantity) desc
end;

-- Lấy danh sách 20 sản phẩm mới về trong tháng
GO
/****** Object:  StoredProcedure [dbo].[prGetCategoryPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetCategoryPaging]
(@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CE as(
		select Categories.Id,Categories.ThumbnailImagePath,Categories.Name,(select COUNT(*) from Products where Products.CategoryId=Categories.Id) as NumbProduct,
		Categories.[Description]
		from Categories
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.Id
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage row only
end;
---Lấy danh sách sản phẩm phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetCustomerById]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetCustomerById]
(@customerId varchar(12))
as
begin
	select Customers.Id,AppUsers.UserName,
	Customers.FullName,
	Customers.Dob, Customers.Address as FullAddress,
	Customers.Gender, Customers.AvatarPath,Customers.IsDelete,Customers.CustomerTypeId
	from Customers
	left join AppUsers on Customers.UserId=AppUsers.Id
	where Customers.Id=@customerId and Customers.IsDelete=0
end;
---Lấy công nợ khách hàng
GO
/****** Object:  StoredProcedure [dbo].[prGetCustomerHistoryPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetCustomerHistoryPaging]
(@customerId varchar(12),@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CE as(
		select OrderDetails.OrderId, OrderStatuses.Name as OrderStatus,
		case
			when ShippingOrders.OrderId is null then N'Đã nhận hàng'
			else ShippingStatus.Name
		end as ShippingStatus, 
		PaymentStatuses.Name as PaymentStatus,
		SUM(OrderDetails.Quantity*OrderDetails.UnitPrice) as TotalAmount,Orders.DateCreated as OrderDate
		from OrderDetails
		inner join Orders on Orders.Id=OrderDetails.OrderId
		inner join OrderStatuses on OrderStatuses.Id=Orders.OrderStatusId
		inner join PaymentStatuses on PaymentStatuses.Id=Orders.PaymentStatusId
		left join ShippingOrders on ShippingOrders.OrderId=Orders.Id
		left join ShippingStatus on ShippingStatus.Id=ShippingOrders.ShippingStatusId
		where Orders.CustomerId=@customerId
		group by OrderDetails.OrderId,OrderStatuses.Name,ShippingOrders.OrderId,Orders.DateCreated,PaymentStatuses.Name,ShippingStatus.Name	
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.OrderId desc
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage row only
end;
---Lấy danh sách nhân viên phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetCustomerPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetCustomerPaging]
(@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CE as(
		select Customers.Id,ISNULL(AppUsers.UserName,'') as UserName,
		Customers.FullName,
		ISNULL(AppUsers.PhoneNumber,Customers.DefaultPhoneNumber) as PhoneNumber,AppUsers.Email,Customers.Address as FullAddress,
		CustomerTypes.Name as CustomerTypeName
		from Customers
		left join AppUsers on Customers.UserId=AppUsers.Id
		left join CustomerTypes on CustomerTypes.Id=Customers.CustomerTypeId
	where Customers.IsDelete=0
	), Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.Id
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage rows only
end;

---Lấy chi tiết thông tin khách hàng theo Id
GO
/****** Object:  StoredProcedure [dbo].[prGetEmployeeById]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetEmployeeById]
(@employeeId varchar(12))
as 
begin
	select Employees.Id,AppUsers.UserName,
    Employees.FullName,Employees.Dob,Employees.Address,Employees.Gender,
	Employees.AvatarPath
    from Employees
	left join AppUsers on AppUsers.Id=Employees.UserId
	where Employees.Id=@employeeId and Employees.IsDelete=0
end;
---Lấy danh sách danh mục phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetEmployeePaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetEmployeePaging]
(@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CE as(
		select Employees.Id,AppUsers.UserName,
		Employees.FullName,
		AppUsers.Email, AppUsers.PhoneNumber,Employees.IsDelete
		from Employees
		left join AppUsers on AppUsers.Id=Employees.UserId
		where Employees.IsDelete=0
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.Id
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage row only
end;
---Lấy chi tiết nhân viên theo Id
GO
/****** Object:  StoredProcedure [dbo].[prGetFeaturedProducts]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetFeaturedProducts]
as
begin
	select top 16 Products.Id,Products.Name,Products.RetailPrice,
	Products.StarScore,Products.Views,Brands.Name as BrandName,
	(select FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ImagePath
	from OrderDetails
	left join Products on Products.Id=OrderDetails.ProductId
	left join Brands on Brands.Id=Products.BrandId
	group by OrderDetails.ProductId,Products.Id,Products.Name,Products.RetailPrice,Products.StarScore,Products.Views,Brands.Name
	order by SUM(OrderDetails.Quantity) desc
end;
--Lấy danh sách tài khoản trong hệ thống phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetNewArrivedProducts]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetNewArrivedProducts]
as
begin
	select top 20 PurchaseOrderDetails.ProductId as Id,Products.Name,
	Products.RetailPrice,
	Products.StarScore, Brands.Name as BrandName,
	Products.Views,(select FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ImagePath
	from PurchaseOrderDetails
	inner join PurchaseOrders on PurchaseOrders.Id=PurchaseOrderDetails.PurchaseOrderId
	left join Products on Products.Id=PurchaseOrderDetails.ProductId
	left join Brands on Brands.Id=Products.BrandId
	where MONTH(PurchaseOrders.PurchaseDate)=MONTH(GETDATE()) and YEAR(PurchaseOrders.PurchaseDate)=YEAR(GETDATE()) and Products.IsDelete=0
	group by PurchaseOrderDetails.ProductId,Products.Name,Products.RetailPrice,Products.StarScore,
	Brands.Name,Products.Views,Products.Id
end;
-- Lấy danh sách 16 sản phẩm được nhiều lượt xem
GO
/****** Object:  StoredProcedure [dbo].[prGetProductDetail]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetProductDetail]
(@productId varchar(12))
as
begin
	select Products.Id,Products.Name,
	Products.Information,Categories.Name as CategoryName,
	Products.[Description],Products.Views ,StarScore,
	Products.RetailPrice,Products.WholesalePrices,
	WarrantyPeriod,Brands.Name as BrandName
	from Products
	left join Categories on Categories.Id=Products.CategoryId
	left join Brands on Brands.Id=Products.BrandId
	where Products.Id=@productId
end;

---Lấy thông tin sản phẩm trong kho phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetProductInStockPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetProductInStockPaging]
(@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CE as(
		select (select ImagePath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ThumbnailPath,
		Products.Name,Products.Id,Categories.Name as CategoryName, Brands.Name as BrandName,Stocks.AbleToSale,Stocks.Inventory
		from Stocks
		inner join Products on Products.Id=Stocks.ProductId
		left join Categories on Categories.Id=Products.CategoryId
		left join Brands on Brands.Id=Products.BrandId
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.Id
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage row only
end;
--
select * from Suppliers 
-- Lấy ngẫu nhiên 12 sản phẩm theo danh mục
GO
/****** Object:  StoredProcedure [dbo].[prGetProductPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetProductPaging]
(@pageNumber int,@rowsOfPage int)
as
begin
	with Main_CE as(
		select (select ProductImages.FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ThumbnailPath,
		Products.Id,
		Products.Name as ProductName,
		Categories.Name as CategoryName,
		Brands.Name as BrandName,
		Stocks.AbleToSale
		from Products
		left join Stocks on Stocks.ProductId=Products.Id
		left join Categories on Categories.Id=Products.CategoryId
		left join Brands on Brands.Id=Products.BrandId
		where IsDelete=0 and Stocks.AbleToSale > 0
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.Id desc
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage row only
end;
---Lấy chi tiết sản phẩm
GO
/****** Object:  StoredProcedure [dbo].[prGetProductsTopRated]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetProductsTopRated]
as
begin
	select top 16 Products.Id, Products.Name,Products.RetailPrice,
	Products.StarScore,Products.Views,Brands.Name as BrandName,
	(select FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ImagePath
	from Products 
	left join Brands on Brands.Id=Products.BrandId
	WHERE Products.StarScore >=1 and Products.IsDelete=0
	order by Products.StarScore desc
end;
--Lấy danh sách 16 sản phẩm bán chạy nhất tháng
GO
/****** Object:  StoredProcedure [dbo].[prGetProductsTopViewed]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetProductsTopViewed]
as
begin
	select top 16 Products.Id as Id, Products.Name,Products.RetailPrice,
	Products.StarScore,Products.Views,Brands.Name as BrandName,
	(select FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ImagePath
	from Products
	left join Brands on Brands.Id=Products.BrandId 
	where Products.Views >= 1000 and Products.IsDelete=0
	order by Products.Views desc
end;
--Lấy danh sách 16 sản phẩm được nhiều lượt bình chọn 
GO
/****** Object:  StoredProcedure [dbo].[prGetRandomProduct]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetRandomProduct]
as 
begin
	select top 6 Products.Id,Products.Name,
	Products.RetailPrice, 
	Products.StarScore, Brands.Name as BrandName, Categories.Name as CategoryName,
	Products.Views,(select FullPath from ProductImages where ProductImages.ProductId=Products.Id and ProductImages.IsThumbnail=1) as ImagePath
	from Products
	left join Categories on Categories.Id=Products.CategoryId
	left join Brands on Brands.Id=Products.BrandId
	where Products.IsDelete=0
	order by NEWID()
end;
-- Lấy danh sách 16 sản phẩm bán chạy trong tháng theo danh mục
GO
/****** Object:  StoredProcedure [dbo].[prGetSupplierById]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetSupplierById]
(@supplierId varchar(12))
as
begin
	select Suppliers.Id,Suppliers.Name, Suppliers.Address,
	Suppliers.PhoneNumber,Suppliers.Email,Suppliers.Fax,
	Employees.FullName as EmployeeName,
	Suppliers.Website,Suppliers.[Description]
	from Suppliers 
	left join Employees on Employees.Id=Suppliers.EmployeeId
	where Suppliers.Id=@supplierId and Suppliers.IsDelete=0
end;
---Lấy lịch sử nhập hàng nhà cung cấp phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetSupplierGoodsReceiptHistories]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetSupplierGoodsReceiptHistories]
(@supplierId varchar(12),@pageNumber int,@rowsOfPage int)
as 
begin
	with Main_CE as(
		SELECT PurchaseOrderDetails.PurchaseOrderId,OrderStatuses.Name as OrderStatus,
		PaymentStatuses.Name as PaymentStatus,
		SUM(PurchaseOrderDetails.Quantity*PurchaseOrderDetails.UnitPrice) as TotalAmount,
		PurchaseOrders.DateCreated
		from PurchaseOrderDetails
		inner join PurchaseOrders on PurchaseOrders.Id=PurchaseOrderDetails.PurchaseOrderId
		left join PaymentVouchers on PaymentVouchers.PurchaseOrderId=PurchaseOrders.Id
		left join OrderStatuses on OrderStatuses.Id=PurchaseOrders.OrderStatusId
		left join PaymentStatuses on PaymentStatuses.Id=PurchaseOrders.PaymentStatusId
		where PurchaseOrders.SupplierId=@supplierId
		group by PurchaseOrderDetails.PurchaseOrderId,OrderStatuses.Name,PaymentStatuses.Name,PurchaseOrders.DateCreated,PurchaseOrders.Id
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.PurchaseOrderId desc
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage rows only
end;

---Lấy danh sách khách hàng phân trang
GO
/****** Object:  StoredProcedure [dbo].[prGetSupplierPaging]    Script Date: 9/17/2020 7:38:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[prGetSupplierPaging]
(@pageNumber int,@rowsOfPage int)
as
begin
	WITH Main_CE as(
		select Suppliers.Id,Suppliers.Name,
		Suppliers.Address as FullAddress,
		Suppliers.Email,
		Suppliers.PhoneNumber
		from Suppliers
		left join Employees on Employees.Id=Suppliers.EmployeeId
		where Suppliers.IsDelete=0
	),Count_CE as(
		select COUNT(*) as [TotalRecord] from Main_CE
	)
	select * from Main_CE,Count_CE
	order by Main_CE.Id
	offset (@pageNumber-1)*@rowsOfPage rows
	fetch next @rowsOfPage rows only
end;
---Lấy chi tiết nhà cung cấp theo Id
GO
USE [master]
GO
ALTER DATABASE [DB_eQACoLTD] SET  READ_WRITE 
GO
