require("Common")

tile_air = 0x0FF
tile_unknown = 0x0FE
tile_unknown_solid = 0x2E0
tile_interior = 0x081
tile_bottom_edge_1 = 0x2A0
tile_bottom_edge_2 = 0x2A1
tile_right_edge_1 = 0x2C0
tile_right_edge_2 = 0x2C1
tile_bottom_right_outside_corner = 0x2C4
tile_top_left_inside_corner = 0x22C

tile_half_bottom_edge_1 = 0x224
tile_half_bottom_edge_2 = 0x225
tile_under_half_bottom_edge_1 = 0x244
tile_under_half_bottom_edge_2 = 0x245

tile_half_left_edge_1 = 0x267
tile_half_left_edge_2 = 0x287
tile_beside_half_left_edge_1 = 0x266
tile_beside_half_left_edge_2 = 0x286

tile_bottom_left_45_slope = 0x2BC  -- this isn't the right tile for this

tile_bottom_left_steep_slope_large = 0x269
tile_bottom_left_steep_slope_small = 0x249
tile_beside_bottom_left_steep_slope_small = 0x248

tile_bottom_right_gentle_slope_large = 0x2AA
tile_bottom_right_gentle_slope_small = 0x2A9
tile_below_bottom_right_gentle_slope_small = 0x2C9

tile_step_small = 0x14E


-- Invariant tiles (non-black CRE tiles): leave them unchanged
if invariant(0, 0) then
    return true
end

-- Air tiles: blank them out:
if air(0, 0) then
    t:set_gfx(tile_number_air, false, false)
    return true
end

-- Slope tiles: use a matching shape
if t:type(0, 0) == 1 then
    bts = t:bts(0, 0) & 0x3F
    if bts == bts_slope_bottom_right_45 then
        t:set_gfx(tile_bottom_left_45_slope, not bts_hflip(0, 0), bts_vflip(0, 0))
        return true
    end
    if bts == bts_slope_bottom_right_steep_small then
        t:set_gfx(tile_bottom_left_steep_slope_small, not bts_hflip(0, 0), bts_vflip(0, 0))
        return true
    end
    if bts == bts_slope_bottom_right_steep_large then
        t:set_gfx(tile_bottom_left_steep_slope_large, not bts_hflip(0, 0), bts_vflip(0, 0))
        return true
    end
    if bts == bts_slope_bottom_right_gentle_small then
        t:set_gfx(tile_bottom_right_gentle_slope_small, bts_hflip(0, 0), bts_vflip(0, 0))
        return true
    end
    if bts == bts_slope_bottom_right_gentle_large then
        t:set_gfx(tile_bottom_right_gentle_slope_large, bts_hflip(0, 0), bts_vflip(0, 0))
        return true
    end
    if t:bts(0, 0) == bts_slope_whole_bottom_edge and air(0, -1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_bottom_edge_1, false, false)
        else
            t:set_gfx(tile_bottom_edge_2, false, false)
        end
        return true
    end
    if t:bts(0, 0) == bts_slope_whole_bottom_edge | 0x80 and air(0, 1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_bottom_edge_1, false, true)
        else
            t:set_gfx(tile_bottom_edge_2, false, true)
        end
        return true
    end    
    if (t:bts(0, 0) & 0xBF == bts_slope_half_bottom_edge_1 or t:bts(0, 0) & 0xBF == bts_slope_half_bottom_edge_1) and solid(0, 1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_half_bottom_edge_1, false, false)
        else
            t:set_gfx(tile_half_bottom_edge_2, false, false)
        end
        return true
    end
    if (t:bts(0, 0) & 0xBF == bts_slope_half_bottom_edge_1 | 0x80 or t:bts(0, 0) & 0xBF == bts_slope_half_bottom_edge_2 | 0x80) and solid(0, -1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_half_bottom_edge_1, false, true)
        else
            t:set_gfx(tile_half_bottom_edge_2, false, true)
        end
        return true
    end
    if t:bts(0, 0) & 0x3F == bts_slope_half_right_edge then
        if t:abs_y() % 2 == 0 then
            t:set_gfx(tile_half_left_edge_1, not bts_hflip(0, 0), false)
        else
            t:set_gfx(tile_half_left_edge_2, not bts_hflip(0, 0), false)
        end
        return true
    end
    if t:bts(0, 0) & 0x3F == bts_slope_step_small then
        t:set_gfx(tile_step_small, bts_hflip(0, 0), bts_vflip(0, 0))
        return true
    end    
end

-- Solid tiles: look at neighboring edges
if solid(0, 0) then
    -- Outside corners (opaque):
    if outside(-1, 0) and solid_left(1, 0) and outside(0, -1) and solid_top(0, 1) then
        t:set_gfx(tile_bottom_right_outside_corner, false, false)
        return true
    end
    if outside(1, 0) and solid_right(-1, 0) and outside(0, -1) and solid_top(0, 1) then
        t:set_gfx(tile_bottom_right_outside_corner, true, false)
        return true
    end
    if outside(-1, 0) and solid_left(1, 0) and outside(0, 1) and solid_bottom(0, -1) then
        t:set_gfx(tile_bottom_right_outside_corner, false, true)
        return true
    end
    if outside(1, 0) and solid_right(-1, 0) and outside(0, 1) and solid_bottom(0, -1) then
        t:set_gfx(tile_bottom_right_outside_corner, true, true)
        return true
    end

    -- Horizontal/vertical edges (opaque):
    if outside(-1, 0) and solid_left(1, 0) and solid_bottom(0, -1) and solid_top(0, 1) then
        if t:abs_y() % 2 == 0 then
            t:set_gfx(tile_right_edge_1, false, false)
        else
            t:set_gfx(tile_right_edge_2, false, false)
        end
        return true
    end
    if outside(1, 0) and solid_right(-1, 0) and solid_bottom(0, -1) and solid_top(0, 1) then
        if t:abs_y() % 2 == 0 then
            t:set_gfx(tile_right_edge_1, true, false)
        else
            t:set_gfx(tile_right_edge_2, true, false)
        end
        return true
    end
    if solid_right(-1, 0) and solid_left(1, 0) and outside(0, -1) and solid_top(0, 1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_bottom_edge_1, false, false)
        else
            t:set_gfx(tile_bottom_edge_2, false, false)
        end
        return true
    end
    if solid_right(-1, 0) and solid_left(1, 0) and outside(0, 1) and solid_bottom(0, -1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_bottom_edge_1, false, true)
        else
            t:set_gfx(tile_bottom_edge_2, false, true)
        end
        return true
    end

    -- Slope adjacent:
    if t:type(-1, 0) == 1 and t:bts(-1, 0) & 0x7F == bts_slope_bottom_right_steep_small and solid_left(1, 0) then
        t:set_gfx(tile_beside_bottom_left_steep_slope_small, true, bts_vflip(-1, 0))
        return true
    end
    if t:type(1, 0) == 1 and t:bts(1, 0) & 0x7F == bts_slope_bottom_right_steep_small | 0x40 and solid_right(-1, 0) then
        t:set_gfx(tile_beside_bottom_left_steep_slope_small, false, bts_vflip(1, 0))
        return true
    end
    if t:type(0, -1) == 1 and t:bts(0, -1) & 0xBF == bts_slope_bottom_right_gentle_small and solid_top(0, 1) then
        t:set_gfx(tile_below_bottom_right_gentle_slope_small, bts_hflip(0, -1), false)
        return true
    end
    if t:type(0, 1) == 1 and t:bts(0, 1) & 0xBF == bts_slope_bottom_right_gentle_small | 0x80 and solid_bottom(0, -1) then
        t:set_gfx(tile_below_bottom_right_gentle_slope_small, bts_hflip(0, 1), true)
        return true
    end
    if t:type(0, -1) == 1 and (t:bts(0, -1) & 0xBF == bts_slope_half_bottom_edge_1 or t:bts(0, -1) & 0xBF == bts_slope_half_bottom_edge_2) and solid_top(0, 1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_under_half_bottom_edge_1, bts_hflip(0, 1), false)
        else
            t:set_gfx(tile_under_half_bottom_edge_2, bts_hflip(0, 1), false)
        end
        return true
    end
    if t:type(0, 1) == 1 and (t:bts(0, 1) & 0xBF == bts_slope_half_bottom_edge_1 | 0x80 or t:bts(0, 1) & 0xBF == bts_slope_half_bottom_edge_2 | 0x80) and solid_bottom(0, -1) then
        if t:abs_x() % 2 == 0 then
            t:set_gfx(tile_under_half_bottom_edge_1, bts_hflip(0, 1), true)
        else
            t:set_gfx(tile_under_half_bottom_edge_2, bts_hflip(0, 1), true)
        end
        return true
    end
    if t:type(-1, 0) == 1 and (t:bts(-1, 0) & 0x7F == bts_slope_half_right_edge) then
        if t:abs_y() % 2 == 0 then
            t:set_gfx(tile_beside_half_left_edge_1, true, false)
        else
            t:set_gfx(tile_beside_half_left_edge_2, true, false)
        end
        return true
    end
    if t:type(1, 0) == 1 and (t:bts(1, 0) & 0x7F == bts_slope_half_right_edge | 0x40) then
        if t:abs_y() % 2 == 0 then
            t:set_gfx(tile_beside_half_left_edge_1, false, false)
        else
            t:set_gfx(tile_beside_half_left_edge_2, false, false)
        end
        return true
    end

    if solid_right(-1, 0) and solid_left(1, 0) and solid_bottom(0, -1) and solid_top(0, 1) then
        -- Inside corners:
        if outside(-1, -1) and not air(1, -1) and not air(-1, 1) and not air(1, 1) then
            t:set_gfx(tile_top_left_inside_corner, true, true)
            return true
        end
        if not air(-1, -1) and outside(1, -1) and not air(-1, 1) and not air(1, 1) then
            t:set_gfx(tile_top_left_inside_corner, false, true)
            return true
        end
        if not air(-1, -1) and not air(1, -1) and outside(-1, 1) and not air(1, 1) then
            t:set_gfx(tile_top_left_inside_corner, true, false)
            return true
        end
        if not air(-1, -1) and not air(1, -1) and not air(-1, 1) and outside(1, 1) then
            t:set_gfx(tile_top_left_inside_corner, false, false)
            return true
        end

        -- Interior
        if not air(-1, -1) and not air(1, -1) and not air(-1, 1) and not air(1, 1) then
            t:set_gfx(tile_interior, false, false)
            return true
        end
    end

    -- Other solid tiles: fall back to metal block (to be easy to spot for manual editing)
    t:set_gfx(tile_unknown_solid, false, false)
    return true
end

-- Other tiles: mark as unknown (X's)
t:set_gfx(tile_unknown, false, false)