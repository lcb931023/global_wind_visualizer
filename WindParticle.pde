/** Wind Particle *** 
    spawns randomly on the map
    moves each frame according to the wind vector at its position. 
        Maybe a certain percentage of that vector?
    relocates randomly after lifespan ends
    wraps around the bound if next movement is out of it
***                  **/

class WindParticle
{
    PVector pos;
    int savedTimer;
    public WindParticle()
    {
        pos = new PVector( random(MAP_W), random(MAP_H) );
        point( pos.x, pos.y );
        savedTimer = millis();
    }

    public void update(int respawnQueueIndex)
    {
        checkLife(respawnQueueIndex);
        pos.add(mapPosToWind());
        wrapBound();
        point( pos.x, pos.y );
    }
    
    private void checkLife(int respawnQueueIndex)
    {
        // use the particle's own index to separate when they get respawned,
        // so they respawn at separate times
        if ( millis() - savedTimer > PARTICLE_LIFESPAN - int(respawnQueueIndex / 5) )
        {
            pos.set(random(MAP_W), random(MAP_H));
            savedTimer = millis();
        }
    }
    
    private void wrapBound()
    {
        if (pos.x < 0) {pos.x = MAP_W - pos.x;}
        if (pos.x >= MAP_W) {pos.x -= MAP_W;}
        if (pos.y < 0) {pos.y = MAP_H - pos.y;}
        if (pos.y >= MAP_H) {pos.y -= MAP_H;}
    }
    
    private PVector mapPosToWind()
    {
        PVector uv = new PVector();
        // due to how big them wind vector numbers are, 
        // in order to animate them smoothly, they need to be weighted down, and possibly distributed unevenly
        float weight = 0.05;
        int mappedI = floor(pos.x/MAP_MULTI);
        int mappedJ = floor(pos.y/MAP_MULTI);
        if (mappedI >= nx)
        {
            println("I going off");
            println(pos.x);
            println(pos.x/MAP_MULTI);
            println(mappedI);
        }
        if (mappedJ >= ny)
        {
            println("J going off");
            println(pos.y);
            println(pos.y/MAP_MULTI);
            println(mappedJ);
        }
        float u = windUComps[mappedJ][mappedI];
        float v = windVComps[mappedJ][mappedI];
        v *= -1; // v need to be flipped to become y
        uv.set(u * weight, v * weight);
        return uv;
    }
}
