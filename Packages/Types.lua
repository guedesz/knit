
--//MODULES
local Types = {}

export type Hero = {
    Name: string,
    Speed: number,
    DelayBetweenHits: number,
    DistanceToHit: number,
    Damage: number,
    Cost: number,
    Health: number,
}

export type Monster = {
    Name: string,
    Speed: number,
    DelayBetweenHits: number,
    DistanceToHit: number,
    Damage: number,
    Health: number,
}

return Types