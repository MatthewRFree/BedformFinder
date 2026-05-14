function [epsg] = getEPSGFromString(crs)
    switch crs
        case 'NAD_1983_2011_StatePlane_New_York_East_FIPS_3101_Ft_US'
            epsg = 6537;
        case 'NAD_1983_BLM_Zone_15N_ftUS'
            epsg = 32165;
        case 'NAD_1983_BLM_Zone_16N_ftUS'
            epsg = 32166;
        case 'NAD_1983_StatePlane_Arkansas_North_FIPS_0301_Feet'
            epsg = 3433;
        case 'NAD_1983_StatePlane_Arkansas_South_FIPS_0302_Feet'
            epsg = 3434;
        case 'NAD_1983_StatePlane_California_III_FIPS_0403_Feet'
            epsg = 2227;
        case 'NAD_1983_StatePlane_California_II_FIPS_0402_Feet'
            epsg = 2226;
        case 'NAD_1983_StatePlane_California_IV_FIPS_0404_Feet'
            epsg = 2228;
        case 'NAD_1983_StatePlane_California_I_FIPS_0401_Feet'
            epsg = 2225;
        case 'NAD_1983_StatePlane_California_VI_FIPS_0406_Feet'
            epsg = 2230;
        case 'NAD_1983_StatePlane_California_V_FIPS_0405_Feet'
            epsg = 2229;
        case 'NAD_1983_StatePlane_Connecticut_FIPS_0600_Feet'
            epsg = 2234;
        case 'NAD_1983_StatePlane_Delaware_FIPS_0700_Feet'
            epsg = 2235;
        case 'NAD_1983_StatePlane_Florida_East_FIPS_0901_Feet'
            epsg = 2236;
        case 'NAD_1983_StatePlane_Florida_North_FIPS_0903_Feet'
            epsg = 2238;
        case 'NAD_1983_StatePlane_Florida_West_FIPS_0902_Feet'
            epsg = 2237;
        case 'NAD_1983_StatePlane_Georgia_East_FIPS_1001_Feet'
            epsg = 2239;
        case 'NAD_1983_StatePlane_Illinois_East_FIPS_1201_Feet'
            epsg = 3435;
        case 'NAD_1983_StatePlane_Illinois_West_FIPS_1202_Feet'
            epsg = 3436;
        case 'NAD_1983_StatePlane_Indiana_West_FIPS_1302_Feet'
            epsg = 2966;
        case 'NAD_1983_StatePlane_Iowa_North_FIPS_1401_Feet'
            epsg = 3417;
        case 'NAD_1983_StatePlane_Iowa_North_FIPS_1401_IntlFeet'
            epsg = 3417;
        case 'NAD_1983_StatePlane_Kentucky_North_FIPS_1601_Feet'
            epsg = 2246;
        case 'NAD_1983_StatePlane_Kentucky_South_FIPS_1602_Feet'
            epsg = 2247;
        case 'NAD_1983_StatePlane_Louisiana_South_FIPS_1702_Feet'
            epsg = 3452;
        case 'NAD_1983_StatePlane_Maine_East_FIPS_1801_Feet'
            epsg = 26847;
        case 'NAD_1983_StatePlane_Maine_West_FIPS_1802_Feet'
            epsg = 26848;
        case 'NAD_1983_StatePlane_Maryland_FIPS_1900_Feet'
            epsg = 2248;
        case 'NAD_1983_StatePlane_Massachusetts_Island_FIPS_2002_Feet'
            epsg = 2250;
        case 'NAD_1983_StatePlane_Massachusetts_Mainland_FIPS_2001_Feet'
            epsg = 2249;
        case 'NAD_1983_StatePlane_Minnesota_North_FIPS_2201_Feet'
            epsg = 26849;
        case 'NAD_1983_StatePlane_Minnesota_South_FIPS_2203_Feet'
            epsg = 26851;
        case 'NAD_1983_StatePlane_Minnesota_South_FIPS_2203_IntlFeet'
            epsg = 26851;
        case 'NAD_1983_StatePlane_Mississippi_East_FIPS_2301_Feet'
            epsg = 2254;
        case 'NAD_1983_StatePlane_Mississippi_West_FIPS_2302_Feet'
            epsg = 2255;
        case 'NAD_1983_StatePlane_New_Hampshire_FIPS_2800_Feet'
            epsg = 3437;
        case 'NAD_1983_StatePlane_New_Jersey_FIPS_2900_Feet'
            epsg = 3424;
        case 'NAD_1983_StatePlane_New_York_Central_FIPS_3102_Feet'
            epsg = 2261;
        case 'NAD_1983_StatePlane_New_York_East_FIPS_3101_Feet'
            epsg = 2260;
        case 'NAD_1983_StatePlane_New_York_Long_Island_FIPS_3104_Feet'
            epsg = 2263;
        case 'NAD_1983_StatePlane_New_York_West_FIPS_3103_Feet'
            epsg = 2262;
        case 'NAD_1983_StatePlane_North_Carolina_FIPS_3200_Feet'
            epsg = 2264;
        case 'NAD_1983_StatePlane_Ohio_North_FIPS_3401_Feet'
            epsg = 3734;
        case 'NAD_1983_StatePlane_Ohio_South_FIPS_3402_Feet'
            epsg = 3735;
        case 'NAD_1983_StatePlane_Oklahoma_North_FIPS_3501_Feet'
            epsg = 2267;
        case 'NAD_1983_StatePlane_Pennsylvania_North_FIPS_3701_Feet'
            epsg = 2271;
        case 'NAD_1983_StatePlane_Pennsylvania_South_FIPS_3702_Feet'
            epsg = 2272;
        case 'NAD_1983_StatePlane_Rhode_Island_FIPS_3800_Feet'
            epsg = 3438;
        case 'NAD_1983_StatePlane_South_Carolina_FIPS_3900_Feet_Intl'
            epsg = 2273;
        case 'NAD_1983_StatePlane_Tennessee_FIPS_4100_Feet'
            epsg = 2274;
        case 'NAD_1983_StatePlane_Texas_South_Central_FIPS_4204_Feet'
            epsg = 2278;
        case 'NAD_1983_StatePlane_Texas_South_FIPS_4205_Feet'
            epsg = 2279;
        case 'NAD_1983_StatePlane_Virginia_North_FIPS_4501_Feet'
            epsg = 2283;
        case 'NAD_1983_StatePlane_Virginia_South_FIPS_4502_Feet'
            epsg = 2284;
        case 'NAD_1983_StatePlane_Washington_North_FIPS_4601_Feet'
            epsg = 2285;
        case 'NAD_1983_StatePlane_Washington_South_FIPS_4602_Feet'
            epsg = 2286;
        case 'NAD_1983_StatePlane_West_Virginia_North_FIPS_4701_Feet'
            epsg = 26853;
        case 'NAD_1983_StatePlane_West_Virginia_South_FIPS_4702_Feet'
            epsg = 26854;
        case 'NAD_1983_StatePlane_Wisconsin_Central_FIPS_4802_Feet'
            epsg = 2288;
        case 'NAD_1983_StatePlane_Wisconsin_North_FIPS_4801_Feet'
            epsg = 2287;
        case 'NAD_1983_StatePlane_Wisconsin_South_FIPS_4803_Feet'
            epsg = 2289;
        otherwise
            epsg = [];
    end
end