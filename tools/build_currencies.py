#!/usr/bin/env python3
"""
build_currencies.py — (re)generate geo/currencies/currencies.json from a canonical
ISO 4217 table, deriving the primary issuing country from geo/countries/countries.json.

Deterministic and reproducible: the ISO 4217 data (code, English name, common symbol,
minor-unit count) lives in the CANON table below; the issuing country/country_code is
resolved from countries.json (most-populous holder wins) so the two datasets stay in
sync. Currencies with no matching country (regional/supranational) carry an explicit
region label.

Source of truth for codes / minor units: ISO 4217:2015 + amendments (SIX Financial
maintenance agency). Verify against https://www.six-group.com/iso4217 for production use.

Run:  python3 tools/build_currencies.py            # writes the file
      python3 tools/build_currencies.py --check    # fail if file would change (CI)
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# code: (English name, common symbol, minor units)
# Minor units follow ISO 4217: 0 (JPY, KRW, ...), 2 (most), 3 (Gulf dinars).
CANON = {
    "AED": ("UAE Dirham", "د.إ", 2), "AFN": ("Afghan Afghani", "؋", 2),
    "ALL": ("Albanian Lek", "L", 2), "AMD": ("Armenian Dram", "֏", 2),
    "AOA": ("Angolan Kwanza", "Kz", 2), "ARS": ("Argentine Peso", "$", 2),
    "AUD": ("Australian Dollar", "A$", 2), "AZN": ("Azerbaijani Manat", "₼", 2),
    "BAM": ("Bosnia-Herzegovina Convertible Mark", "KM", 2),
    "BBD": ("Barbadian Dollar", "Bds$", 2), "BDT": ("Bangladeshi Taka", "৳", 2),
    "BGN": ("Bulgarian Lev", "лв", 2), "BHD": ("Bahraini Dinar", ".د.ب", 3),
    "BIF": ("Burundian Franc", "FBu", 0), "BND": ("Brunei Dollar", "B$", 2),
    "BOB": ("Bolivian Boliviano", "Bs.", 2), "BRL": ("Brazilian Real", "R$", 2),
    "BSD": ("Bahamian Dollar", "B$", 2), "BTN": ("Bhutanese Ngultrum", "Nu.", 2),
    "BWP": ("Botswana Pula", "P", 2), "BYN": ("Belarusian Ruble", "Br", 2),
    "BZD": ("Belize Dollar", "BZ$", 2), "CAD": ("Canadian Dollar", "C$", 2),
    "CDF": ("Congolese Franc", "FC", 2), "CHF": ("Swiss Franc", "Fr", 2),
    "CLP": ("Chilean Peso", "$", 0), "CNY": ("Chinese Yuan Renminbi", "¥", 2),
    "COP": ("Colombian Peso", "$", 2), "CRC": ("Costa Rican Colón", "₡", 2),
    "CUP": ("Cuban Peso", "$", 2), "CVE": ("Cape Verdean Escudo", "$", 2),
    "CZK": ("Czech Koruna", "Kč", 2), "DJF": ("Djiboutian Franc", "Fdj", 0),
    "DKK": ("Danish Krone", "kr", 2), "DOP": ("Dominican Peso", "RD$", 2),
    "DZD": ("Algerian Dinar", "د.ج", 2), "EGP": ("Egyptian Pound", "£", 2),
    "ERN": ("Eritrean Nakfa", "Nfk", 2), "ETB": ("Ethiopian Birr", "Br", 2),
    "EUR": ("Euro", "€", 2), "FJD": ("Fijian Dollar", "FJ$", 2),
    "GBP": ("British Pound Sterling", "£", 2), "GEL": ("Georgian Lari", "₾", 2),
    "GHS": ("Ghanaian Cedi", "₵", 2), "GMD": ("Gambian Dalasi", "D", 2),
    "GNF": ("Guinean Franc", "FG", 0), "GTQ": ("Guatemalan Quetzal", "Q", 2),
    "GYD": ("Guyanese Dollar", "G$", 2), "HKD": ("Hong Kong Dollar", "HK$", 2),
    "HNL": ("Honduran Lempira", "L", 2), "HRK": ("Croatian Kuna", "kn", 2),
    "HTG": ("Haitian Gourde", "G", 2), "HUF": ("Hungarian Forint", "Ft", 2),
    "IDR": ("Indonesian Rupiah", "Rp", 2), "ILS": ("Israeli New Shekel", "₪", 2),
    "INR": ("Indian Rupee", "₹", 2), "IQD": ("Iraqi Dinar", "ع.د", 3),
    "IRR": ("Iranian Rial", "﷼", 2), "ISK": ("Icelandic Króna", "kr", 0),
    "JMD": ("Jamaican Dollar", "J$", 2), "JOD": ("Jordanian Dinar", "د.ا", 3),
    "JPY": ("Japanese Yen", "¥", 0), "KES": ("Kenyan Shilling", "KSh", 2),
    "KGS": ("Kyrgyzstani Som", "с", 2), "KHR": ("Cambodian Riel", "៛", 2),
    "KMF": ("Comorian Franc", "CF", 0), "KPW": ("North Korean Won", "₩", 2),
    "KRW": ("South Korean Won", "₩", 0), "KWD": ("Kuwaiti Dinar", "د.ك", 3),
    "KZT": ("Kazakhstani Tenge", "₸", 2), "LAK": ("Lao Kip", "₭", 2),
    "LBP": ("Lebanese Pound", "ل.ل", 2), "LKR": ("Sri Lankan Rupee", "Rs", 2),
    "LRD": ("Liberian Dollar", "L$", 2), "LSL": ("Lesotho Loti", "L", 2),
    "LYD": ("Libyan Dinar", "ل.د", 3), "MAD": ("Moroccan Dirham", "د.م.", 2),
    "MDL": ("Moldovan Leu", "L", 2), "MGA": ("Malagasy Ariary", "Ar", 2),
    "MKD": ("Macedonian Denar", "ден", 2), "MMK": ("Myanmar Kyat", "K", 2),
    "MNT": ("Mongolian Tögrög", "₮", 2), "MRU": ("Mauritanian Ouguiya", "UM", 2),
    "MUR": ("Mauritian Rupee", "₨", 2), "MVR": ("Maldivian Rufiyaa", ".ރ", 2),
    "MWK": ("Malawian Kwacha", "MK", 2), "MXN": ("Mexican Peso", "$", 2),
    "MYR": ("Malaysian Ringgit", "RM", 2), "MZN": ("Mozambican Metical", "MT", 2),
    "NAD": ("Namibian Dollar", "N$", 2), "NGN": ("Nigerian Naira", "₦", 2),
    "NIO": ("Nicaraguan Córdoba", "C$", 2), "NOK": ("Norwegian Krone", "kr", 2),
    "NPR": ("Nepalese Rupee", "रू", 2), "NZD": ("New Zealand Dollar", "NZ$", 2),
    "OMR": ("Omani Rial", "ر.ع.", 3), "PAB": ("Panamanian Balboa", "B/.", 2),
    "PEN": ("Peruvian Sol", "S/", 2), "PGK": ("Papua New Guinean Kina", "K", 2),
    "PHP": ("Philippine Peso", "₱", 2), "PKR": ("Pakistani Rupee", "₨", 2),
    "PLN": ("Polish Złoty", "zł", 2), "PYG": ("Paraguayan Guaraní", "₲", 0),
    "QAR": ("Qatari Riyal", "ر.ق", 2), "RON": ("Romanian Leu", "lei", 2),
    "RSD": ("Serbian Dinar", "дин", 2), "RUB": ("Russian Ruble", "₽", 2),
    "RWF": ("Rwandan Franc", "FRw", 0), "SAR": ("Saudi Riyal", "﷼", 2),
    "SBD": ("Solomon Islands Dollar", "SI$", 2), "SCR": ("Seychellois Rupee", "₨", 2),
    "SDG": ("Sudanese Pound", "ج.س.", 2), "SEK": ("Swedish Krona", "kr", 2),
    "SGD": ("Singapore Dollar", "S$", 2), "SLE": ("Sierra Leonean Leone", "Le", 2),
    "SOS": ("Somali Shilling", "Sh", 2), "SRD": ("Surinamese Dollar", "$", 2),
    "SSP": ("South Sudanese Pound", "£", 2),
    "STN": ("São Tomé and Príncipe Dobra", "Db", 2), "SYP": ("Syrian Pound", "£", 2),
    "SZL": ("Eswatini Lilangeni", "L", 2), "THB": ("Thai Baht", "฿", 2),
    "TJS": ("Tajikistani Somoni", "ЅМ", 2), "TMT": ("Turkmenistani Manat", "m", 2),
    "TND": ("Tunisian Dinar", "د.ت", 3), "TOP": ("Tongan Paʻanga", "T$", 2),
    "TRY": ("Turkish Lira", "₺", 2), "TTD": ("Trinidad & Tobago Dollar", "TT$", 2),
    "TWD": ("New Taiwan Dollar", "NT$", 2), "TZS": ("Tanzanian Shilling", "TSh", 2),
    "UAH": ("Ukrainian Hryvnia", "₴", 2), "UGX": ("Ugandan Shilling", "USh", 0),
    "USD": ("United States Dollar", "$", 2), "UYU": ("Uruguayan Peso", "$U", 2),
    "UZS": ("Uzbekistani Som", "so'm", 2), "VES": ("Venezuelan Bolívar Soberano", "Bs.", 2),
    "VND": ("Vietnamese Đồng", "₫", 0), "VUV": ("Vanuatu Vatu", "VT", 0),
    "WST": ("Samoan Tālā", "WS$", 2), "XAF": ("Central African CFA Franc", "FCFA", 0),
    "XCD": ("East Caribbean Dollar", "EC$", 2), "XOF": ("West African CFA Franc", "CFA", 0),
    "XPF": ("CFP Franc", "₣", 0), "YER": ("Yemeni Rial", "﷼", 2),
    "ZAR": ("South African Rand", "R", 2), "ZMW": ("Zambian Kwacha", "ZK", 2),
    "ZWG": ("Zimbabwe Gold (ZiG)", "ZiG", 2),
    # ── territorial / dependency / special codes (not tied to a UN state) ──
    "AWG": ("Aruban Florin", "ƒ", 2),
    "BMD": ("Bermudian Dollar", "$", 2), "KYD": ("Cayman Islands Dollar", "$", 2),
    "FKP": ("Falkland Islands Pound", "£", 2), "GIP": ("Gibraltar Pound", "£", 2),
    "SHP": ("Saint Helena Pound", "£", 2), "GGP": ("Guernsey Pound", "£", 2),
    "JEP": ("Jersey Pound", "£", 2), "IMP": ("Isle of Man Pound", "£", 2),
    "XCG": ("Caribbean Guilder", "ƒ", 2), "XDR": ("IMF Special Drawing Rights", "SDR", 0),
    "XAD": ("Arab Accounting Dinar", "XAD", 2),
}

# regional/territory issuers keyed for the REGION map
REGION_EXTRA = {
    "AWG": ("Aruba", None),
    "BMD": ("Bermuda", None), "KYD": ("Cayman Islands", None),
    "FKP": ("Falkland Islands", None), "GIP": ("Gibraltar", None),
    "SHP": ("Saint Helena, Ascension and Tristan da Cunha", None),
    "GGP": ("Guernsey", None), "JEP": ("Jersey", None), "IMP": ("Isle of Man", None),
    "XCG": ("Curaçao and Sint Maarten (Caribbean guilder)", None),
    "XDR": ("International Monetary Fund", None),
    "XAD": ("Arab Monetary Fund", None),
}

# Currencies not tied to a single country in countries.json (supranational/regional).
REGION = {
    "EUR": ("European Union", "EU"),
    "XAF": ("CEMAC (Central Africa)", None),
    "XOF": ("UEMOA (West Africa)", None),
    "XCD": ("OECS (East Caribbean)", None),
    "XPF": ("French Pacific Territories", None),
    "USD": ("United States", "US"),
}
REGION.update(REGION_EXTRA)

# ISO 4217 numeric codes (SIX/ISO 4217 register). Codes without an official
# numeric assignment (GGP/IMP/JEP local pounds) are intentionally absent.
NUMERIC = {
    "AED": 784, "AFN": 971, "ALL": 8, "AMD": 51, "AOA": 973, "ARS": 32, "AUD": 36, "AWG": 533,
    "AZN": 944, "BAM": 977, "BBD": 52, "BDT": 50, "BGN": 975, "BHD": 48, "BIF": 108, "BMD": 60,
    "BND": 96, "BOB": 68, "BRL": 986, "BSD": 44, "BTN": 64, "BWP": 72, "BYN": 933, "BZD": 84,
    "CAD": 124, "CDF": 976, "CHF": 756, "CLP": 152, "CNY": 156, "COP": 170, "CRC": 188, "CUP": 192,
    "CVE": 132, "CZK": 203, "DJF": 262, "DKK": 208, "DOP": 214, "DZD": 12, "EGP": 818, "ERN": 232,
    "ETB": 230, "EUR": 978, "FJD": 242, "FKP": 238, "GBP": 826, "GEL": 981, "GHS": 936, "GIP": 292,
    "GMD": 270, "GNF": 324, "GTQ": 320, "GYD": 328, "HKD": 344, "HNL": 340, "HRK": 191, "HTG": 332,
    "HUF": 348, "IDR": 360, "ILS": 376, "INR": 356, "IQD": 368, "IRR": 364, "ISK": 352, "JMD": 388,
    "JOD": 400, "JPY": 392, "KES": 404, "KGS": 417, "KHR": 116, "KMF": 174, "KPW": 408, "KRW": 410,
    "KWD": 414, "KYD": 136, "KZT": 398, "LAK": 418, "LBP": 422, "LKR": 144, "LRD": 430, "LSL": 426,
    "LYD": 434, "MAD": 504, "MDL": 498, "MGA": 969, "MKD": 807, "MMK": 104, "MNT": 496, "MRU": 929,
    "MUR": 480, "MVR": 462, "MWK": 454, "MXN": 484, "MYR": 458, "MZN": 943, "NAD": 516, "NGN": 566,
    "NIO": 558, "NOK": 578, "NPR": 524, "NZD": 554, "OMR": 512, "PAB": 590, "PEN": 604, "PGK": 598,
    "PHP": 608, "PKR": 586, "PLN": 985, "PYG": 600, "QAR": 634, "RON": 946, "RSD": 941, "RUB": 643,
    "RWF": 646, "SAR": 682, "SBD": 90, "SCR": 690, "SDG": 938, "SEK": 752, "SGD": 702, "SHP": 654,
    "SLE": 925, "SOS": 706, "SRD": 968, "SSP": 728, "STN": 930, "SYP": 760, "SZL": 748, "THB": 764,
    "TJS": 972, "TMT": 934, "TND": 788, "TOP": 776, "TRY": 949, "TTD": 780, "TWD": 901, "TZS": 834,
    "UAH": 980, "UGX": 800, "USD": 840, "UYU": 858, "UZS": 860, "VES": 928, "VND": 704, "VUV": 548,
    "WST": 882, "XAD": 396, "XAF": 950, "XCD": 951, "XCG": 532, "XDR": 960, "XOF": 952, "XPF": 953,
    "YER": 886, "ZAR": 710, "ZMW": 967, "ZWG": 924,
}


def main():
    check = "--check" in sys.argv[1:]
    countries = json.load(open(os.path.join(ROOT, "geo/countries/countries.json")))

    # primary country per currency code = most populous holder
    primary = {}
    for c in countries:
        code = c.get("currency_code")
        if not code:
            continue
        pop = c.get("population_approx", 0) or 0
        if code not in primary or pop > primary[code][0]:
            primary[code] = (pop, c["name"], c["iso2"])

    out = []
    for code in sorted(CANON):
        name, symbol, decimals = CANON[code]
        if code in REGION:
            country, cc = REGION[code]
        elif code in primary:
            _, country, cc = primary[code]
        else:
            country, cc = None, None
        entry = {"code": code}
        if code in NUMERIC:
            entry["numeric"] = NUMERIC[code]
        entry.update({
            "name": name, "symbol": symbol,
            "decimals": decimals, "country": country, "country_code": cc,
        })
        out.append(entry)

    path = os.path.join(ROOT, "geo/currencies/currencies.json")
    new = json.dumps(out, indent=2, ensure_ascii=False) + "\n"
    if check:
        cur = open(path, encoding="utf-8").read()
        if cur != new:
            print("currencies.json is stale — run tools/build_currencies.py")
            sys.exit(1)
        print("currencies.json up to date")
        return
    open(path, "w", encoding="utf-8").write(new)
    print(f"wrote {len(out)} currencies to geo/currencies/currencies.json")


if __name__ == "__main__":
    main()
