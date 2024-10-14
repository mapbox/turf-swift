set(MAPBOX_TURF_DIR "Turf" CACHE PATH "Turf for Swift directory")

set(SWIFT_SOURCES
    ${MAPBOX_TURF_DIR}/Spline.swift
    ${MAPBOX_TURF_DIR}/FeatureIdentifier.swift
    ${MAPBOX_TURF_DIR}/JSON.swift
    ${MAPBOX_TURF_DIR}/FeatureCollection.swift
    ${MAPBOX_TURF_DIR}/Feature.swift
    ${MAPBOX_TURF_DIR}/Codable.swift
    ${MAPBOX_TURF_DIR}/Ring.swift
    ${MAPBOX_TURF_DIR}/Geometry.swift
    ${MAPBOX_TURF_DIR}/BoundingBox.swift
    ${MAPBOX_TURF_DIR}/Simplifier.swift
    ${MAPBOX_TURF_DIR}/Geometries/Point.swift
    ${MAPBOX_TURF_DIR}/Geometries/MultiPoint.swift
    ${MAPBOX_TURF_DIR}/Geometries/GeometryCollection.swift
    ${MAPBOX_TURF_DIR}/Geometries/LineString.swift
    ${MAPBOX_TURF_DIR}/Geometries/Polygon.swift
    ${MAPBOX_TURF_DIR}/Geometries/MultiLineString.swift
    ${MAPBOX_TURF_DIR}/Geometries/MultiPolygon.swift
    ${MAPBOX_TURF_DIR}/GeoJSON.swift
    ${MAPBOX_TURF_DIR}/CoreLocation.swift
    ${MAPBOX_TURF_DIR}/Consumer/Consumer.swift
    ${MAPBOX_TURF_DIR}/Consumer/Consumer+WKT.swift
    ${MAPBOX_TURF_DIR}/Turf.swift
    ${MAPBOX_TURF_DIR}/RadianCoordinate2D.swift
    ${MAPBOX_TURF_DIR}/WKT.swift
    ${MAPBOX_TURF_DIR}/Turf.h
)

add_library(${FRAMEWORK_NAME} SHARED ${SWIFT_SOURCES})

set_target_properties(${FRAMEWORK_NAME} PROPERTIES
    FRAMEWORK TRUE
    FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
    MACOSX_FRAMEWORK_IDENTIFIER com.mapbox.turf
    Swift_MODULE_NAME ${FRAMEWORK_NAME}
    XCODE_ATTRIBUTE_ENABLE_TESTABILITY[variant=Debug] "YES"
    XCODE_ATTRIBUTE_DYLIB_COMPATIBILITY_VERSION 1
    XCODE_ATTRIBUTE_DYLIB_CURRENT_VERSION 32
)

