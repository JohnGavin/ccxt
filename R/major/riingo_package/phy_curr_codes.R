# phy_curr_codes <- read_delim(clipboard(), delim = '\t')
# dput(phy_curr_codes)
phy_curr_codes <-
  structure(list(`currency code` = c("AED", "AFN", "ALL", "AMD", 
  "ANG", "AOA", "ARS", "AUD", "AWG", "AZN", "BAM", "BBD", "BDT", 
  "BGN", "BHD", "BIF", "BMD", "BND", "BOB", "BRL", "BSD", "BTN", 
  "BWP", "BZD", "CAD", "CDF", "CHF", "CLF", "CLP", "CNH", "CNY", 
  "COP", "CUP", "CVE", "CZK", "DJF", "DKK", "DOP", "DZD", "EGP", 
  "ERN", "ETB", "EUR", "FJD", "FKP", "GBP", "GEL", "GHS", "GIP", 
  "GMD", "GNF", "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", 
  "ICP", "IDR", "ILS", "INR", "IQD", "IRR", "ISK", "JEP", "JMD", 
  "JOD", "JPY", "KES", "KGS", "KHR", "KMF", "KPW", "KRW", "KWD", 
  "KYD", "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "LYD", "MAD", 
  "MDL", "MGA", "MKD", "MMK", "MNT", "MOP", "MRO", "MRU", "MUR", 
  "MVR", "MWK", "MXN", "MYR", "MZN", "NAD", "NGN", "NOK", "NPR", 
  "NZD", "OMR", "PAB", "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", 
  "QAR", "RON", "RSD", "RUB", "RUR", "RWF", "SAR", "SBDf", "SCR", 
  "SDG", "SDR", "SEK", "SGD", "SHP", "SLL", "SOS", "SRD", "SYP", 
  "SZL", "THB", "TJS", "TMT", "TND", "TOP", "TRY", "TTD", "TWD", 
  "TZS", "UAH", "UGX", "USD", "UYU", "UZS", "VND", "VUV", "WST", 
  "XAF", "XCD", "XDR", "XOF", "XPF", "YER", "ZAR", "ZMW", "ZWL"
), `currency name` = c("United Arab Emirates Dirham", "Afghan Afghani", 
  "Albanian Lek", "Armenian Dram", "Netherlands Antillean Guilder", 
  "Angolan Kwanza", "Argentine Peso", "Australian Dollar", "Aruban Florin", 
  "Azerbaijani Manat", "Bosnia-Herzegovina Convertible Mark", "Barbadian Dollar", 
  "Bangladeshi Taka", "Bulgarian Lev", "Bahraini Dinar", "Burundian Franc", 
  "Bermudan Dollar", "Brunei Dollar", "Bolivian Boliviano", "Brazilian Real", 
  "Bahamian Dollar", "Bhutanese Ngultrum", "Botswanan Pula", "Belize Dollar", 
  "Canadian Dollar", "Congolese Franc", "Swiss Franc", "Chilean Unit of Account UF", 
  "Chilean Peso", "Chinese Yuan Offshore", "Chinese Yuan", "Colombian Peso", 
  "Cuban Peso", "Cape Verdean Escudo", "Czech Republic Koruna", 
  "Djiboutian Franc", "Danish Krone", "Dominican Peso", "Algerian Dinar", 
  "Egyptian Pound", "Eritrean Nakfa", "Ethiopian Birr", "Euro", 
  "Fijian Dollar", "Falkland Islands Pound", "British Pound Sterling", 
  "Georgian Lari", "Ghanaian Cedi", "Gibraltar Pound", "Gambian Dalasi", 
  "Guinean Franc", "Guatemalan Quetzal", "Guyanaese Dollar", "Hong Kong Dollar", 
  "Honduran Lempira", "Croatian Kuna", "Haitian Gourde", "Hungarian Forint", 
  "Internet Computer", "Indonesian Rupiah", "Israeli New Sheqel", 
  "Indian Rupee", "Iraqi Dinar", "Iranian Rial", "Icelandic Krona", 
  "Jersey Pound", "Jamaican Dollar", "Jordanian Dinar", "Japanese Yen", 
  "Kenyan Shilling", "Kyrgystani Som", "Cambodian Riel", "Comorian Franc", 
  "North Korean Won", "South Korean Won", "Kuwaiti Dinar", "Cayman Islands Dollar", 
  "Kazakhstani Tenge", "Laotian Kip", "Lebanese Pound", "Sri Lankan Rupee", 
  "Liberian Dollar", "Lesotho Loti", "Libyan Dinar", "Moroccan Dirham", 
  "Moldovan Leu", "Malagasy Ariary", "Macedonian Denar", "Myanma Kyat", 
  "Mongolian Tugrik", "Macanese Pataca", "Mauritanian Ouguiya (pre-2018)", 
  "Mauritanian Ouguiya", "Mauritian Rupee", "Maldivian Rufiyaa", 
  "Malawian Kwacha", "Mexican Peso", "Malaysian Ringgit", "Mozambican Metical", 
  "Namibian Dollar", "Nigerian Naira", "Norwegian Krone", "Nepalese Rupee", 
  "New Zealand Dollar", "Omani Rial", "Panamanian Balboa", "Peruvian Nuevo Sol", 
  "Papua New Guinean Kina", "Philippine Peso", "Pakistani Rupee", 
  "Polish Zloty", "Paraguayan Guarani", "Qatari Rial", "Romanian Leu", 
  "Serbian Dinar", "Russian Ruble", "Old Russian Ruble", "Rwandan Franc", 
  "Saudi Riyal", "Solomon Islands Dollar", "Seychellois Rupee", 
  "Sudanese Pound", "Special Drawing Rights", "Swedish Krona", 
  "Singapore Dollar", "Saint Helena Pound", "Sierra Leonean Leone", 
  "Somali Shilling", "Surinamese Dollar", "Syrian Pound", "Swazi Lilangeni", 
  "Thai Baht", "Tajikistani Somoni", "Turkmenistani Manat", "Tunisian Dinar", 
  "Tongan Pa'anga", "Turkish Lira", "Trinidad and Tobago Dollar", 
  "New Taiwan Dollar", "Tanzanian Shilling", "Ukrainian Hryvnia", 
  "Ugandan Shilling", "United States Dollar", "Uruguayan Peso", 
  "Uzbekistan Som", "Vietnamese Dong", "Vanuatu Vatu", "Samoan Tala", 
  "CFA Franc BEAC", "East Caribbean Dollar", "Special Drawing Rights", 
  "CFA Franc BCEAO", "CFP Franc", "Yemeni Rial", "South African Rand", 
  "Zambian Kwacha", "Zimbabwean Dollar")), row.names = c(NA, -157L
  ), spec = structure(list(cols = list(`currency code` = structure(list(), class = c("collector_character", 
    "collector")), `currency name` = structure(list(), class = c("collector_character", 
      "collector"))), default = structure(list(), class = c("collector_guess", 
        "collector")), delim = "\t"), class = "col_spec"), class = c("spec_tbl_df", 
          "tbl_df", "tbl", "data.frame"))
