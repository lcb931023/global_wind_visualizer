JSONArray windJson;
int ny = 181;
int nx = 360;
float[][] windUComps = new float[ny][nx];
float[][] windVComps = new float[ny][nx];
// maximum intensity in this data sample is 71.67596
// Therefore, mapping the scale to 90 should suffice

void setup()
{
    background(0);
    size(960, 560, P3D);
    frameRate(30);
    smooth();
    // Load Json
    windJson = loadJSONArray("20140501-wind-isobaric-500hPa-gfs-1.0.json");
    JSONObject windU = windJson.getJSONObject(0);
    
    parseWindJson();
}

void draw()
{
    
}

void parseWindJson()
{
    // parse u into a 2d array
    windUComps = parseWindVectorComp(windJson.getJSONObject(0).getJSONArray("data"));
    // parse v into a 2d array
    windVComps = parseWindVectorComp(windJson.getJSONObject(1).getJSONArray("data"));
    
    // show em on a 360 * 180 square
    colorMode(HSB, 180);
    for (int i = 0; i < 360; i++) {
        for (int j = 0; j < 180; j++) {
            float intensity = calcIntensity(windUComps[j][i], windVComps[j][i]);
            int huedI = int(180 - (intensity*180/90 + 60)); // intensity map to 0 ~ 90
            int satuation = 180;
            if (huedI <= 0)
            {
                huedI = 180 + huedI;
                if (huedI < 150)
                {
                    satuation = 180 - (150 - huedI)*5;
                    huedI = 150;
                }
            }
            stroke(huedI, satuation, 180);
            point(i + 390, j + 300);
        }
    }
    colorMode(RGB, 255);
}

float[][] parseWindVectorComp(JSONArray comps)
{
    float[][] result = new float[ny][nx]; // result[j][i] // result[lat][lon]
    int counter = 0;
    for (int j = 0; j < ny; j++)
    {
        for (int i = 0; i < nx; i++)
        {
            result[j][i] = comps.getFloat(counter);
            counter++;
        }
    }
    
    return result;
}

float calcIntensity(float u, float v)
{
    return sqrt(u*u+v*v);
}

void findMaxIntensity()
{
     // Find the maximum intensity for scaling to colours
    float max = 0;
    for (int j = 0; j < ny; j++)
    {
        for (int i = 0; i < nx; i++)
        {
            float intensity = calcIntensity(windUComps[j][i], windVComps[j][i]);
            max = intensity > max ? intensity : max;
        }
    }
    println(max);   
}
