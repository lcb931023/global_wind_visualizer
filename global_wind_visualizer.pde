JSONArray windJson;
int ny = 181;
int nx = 360;
int MAP_MULTI = 2;
float MAP_W = 360 * MAP_MULTI;
float MAP_H = 180 * MAP_MULTI;
float[][] windUComps = new float[ny][nx];
float[][] windVComps = new float[ny][nx];
WindParticle[] flows = new WindParticle[10000];
int PARTICLE_LIFESPAN = 3000;//ms

PGraphics globeTex;
PShape globe;
// globe control
float zoom = 200;
PVector rotation = new PVector(); // vector to store the rotation
PVector velocity = new PVector(); // vector to store the change in rotation
float rotationSpeed = 0.02; // the rotation speed

// maximum intensity in this data sample is 71.67596
// Therefore, mapping the scale to 75 should suffice
void setup()
{
    size(displayWidth, displayHeight, P3D);
    frameRate(30);
    //smooth();
    perspective(PI/3.0, (float) width/height, 0.1, 1000000);
    // Load Json
    windJson = loadJSONArray("20140501-wind-isobaric-500hPa-gfs-1.0.json");
    JSONObject windU = windJson.getJSONObject(0);

    globeTex = createGraphics(int(MAP_W), int(MAP_H));
    globeTex.beginDraw();
    globeTex.strokeCap(PROJECT);
    parseWindJson();
    drawColorMap(180);
    globeTex.stroke(255);
    for (int i = 0; i < flows.length; i++)
    {
        flows[i] = new WindParticle();
    }
    globeTex.endDraw();
    globe = createIcosahedron(6);
}

void draw()
{
    globeTex.beginDraw();
    drawColorMap(10);
    //fill(0, 10);
    //rect(0, 0, MAP_W, MAP_H);
    globeTex.strokeWeight(1);
    //stroke(111, 195, 223, 150);
    globeTex.stroke(255, 150);
    for (int i = 0; i < flows.length; i++)
    {
        flows[i].update(i);
    }
    globeTex.endDraw();
    
    translate(width/2, height/2); // to center of screen
    // mouse control
    if (mousePressed) {
        velocity.x -= (mouseY-pmouseY) * 0.01;
        velocity.y += (mouseX-pmouseX) * 0.01;
    }
    rotation.add(velocity);
    velocity.mult(0.95); // diminish the rotation velocity on each draw()
    rotateX(rotation.x * rotationSpeed);
    rotateY(rotation.y * rotationSpeed);
    scale(zoom);
    
    shape(globe);
    frame.setTitle(" " + int(frameRate)); // write the fps in the top-left of the window
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
    globeTex.colorMode(HSB, 180);
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
            globeTex.noStroke();
            globeTex.fill(huedI, satuation, 100, alpha);
            //point(i*MAP_MULTI, j*MAP_MULTI);
            globeTex.rect(i*MAP_MULTI, j*MAP_MULTI, MAP_MULTI, MAP_MULTI);
        }
    }
    globeTex.colorMode(RGB, 255);
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