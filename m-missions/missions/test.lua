missions[1] = {
    onStart = function(context)
        context:createMarker('specjalnymarker', Vector3(1221.831, -1696.237, 33.805), 'cylinder', 1, {255, 0, 0, 255}, 'siema')
        context:outputChat('Rozpoczęto misję testową')
    end,

    onMarkerHit = function(context, marker)
        if marker == 'specjalnymarker' then
            context:outputChat('wszedłeś w marker')
            context:destroy('specjalnymarker')
        end
    end
}