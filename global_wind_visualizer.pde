JSONArray windJson;
int ny = 181;
int nx = 360;
float MAP_W = 720;
float MAP_H = 360;
int MAP_MULTI = 2;
float[][] windUComps = new float[ny][nx];
float[][] windVComps = new float[ny][nx];
WindParticle[] flows = new WindParticle[10000];
int PARTICLE_LIFESPAN = 7000;//ms
// maximum intensity in this data sample is 71.67596
// Therefore, mapping the scale to 75 should suffice

void setup()
{
    background(0);
    size(960, 560, P3D);
    frameRate(30);
    smooth();
    strokeCap(PROJECT);
    // Load Json
    windJson = loadJSONArray("20140501-wind-isobaric-500hPa-gfs-1.0.json");
    JSONObject windU = windJson.getJSONObject(0);
    
    parseWindJson();
    drawColorMap(180);
    stroke(255);
    for(int i = 0; i < flows.length; i++)
    {
        flows[i] = new WindParticle();
    }
}

void draw()
{
    drawColorMap(10);
    fill(0, 10);
    //rect(0, 0, MAP_W, MAP_H);
    strokeWeight(1);
    stroke(255);
    for(int i = 0; i < flows.length; i++)
    {
        flows[i].update(i);
    }
}

void parseWindJson()
{
    // parse u into a 2d array
    windUComps = parseWindVectorComp(windJson.getJSONObject(0).getJSONArray("data"));
    // parse v into a 2d array
    windVComps = parseWindVectorComp(windJson.getJSONObject(1).getJSONArray("data"));
}

void drawColorMap(int alpha)
{
    colorMode(HSB, 180);
    for (int i = 0; i < 360; i++) {
        for (int j = 0; j < 180; j++) {
            float intensity = calcIntensity(windUComps[j][i], windVComps[j][i]);
            int huedI = int(180 - (intensity*180/ 75 + 60)); // intensity map to 0 ~ 75
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
            //strokeWeight(MAP_MULTI);
            noStroke();
            fill(huedI, satuation, 100, alpha);
            //point(i*MAP_MULTI, j*MAP_MULTI);
            rect(i*MAP_MULTI, j*MAP_MULTI, MAP_MULTI, MAP_MULTI);
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
