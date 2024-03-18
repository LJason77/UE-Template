#pragma once

#include "DrawDebugHelpers.h"

#define DEBUG_DRAW_SPHERE(Location) if (GetWorld()) DrawDebugSphere(GetWorld(), Location, 25.f, 12, FColor::Red, true)
#define DEBUG_DRAW_LINE(StartLocation, EndLocation) if (GetWorld()) DrawDebugLine(GetWorld(), StartLocation, EndLocation, FColor::Red, true, -1.f, 0, 1.f)
#define DEBUG_DRAW_POINT(Location) if (GetWorld()) DrawDebugPoint(GetWorld(), Location, 25.f, FColor::Red, true)
#define DEBUG_DRAW_VECTOR(StartLocation, EndLocation) if (GetWorld()) \
    { \
        DrawDebugLine(GetWorld(), StartLocation, EndLocation, FColor::Red, true, -1.f, 0, 1.f); \
        DrawDebugPoint(GetWorld(), EndLocation, 25.f, FColor::Red, true); \
    }
