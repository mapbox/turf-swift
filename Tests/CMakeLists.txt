find_package(XCTest REQUIRED)

set(MAPBOX_TURF_TESTS_DIR "TurfTests" CACHE PATH "TurfTests for Swift directory")

set(TEST_SOURCES
    ${MAPBOX_TURF_TESTS_DIR}/LocationCoordinate2DTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/RadianCoordinate2DTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/WKTTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/GeometryCollectionTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/GeoJSONTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/TurfTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/PointTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/LineStringTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/PolygonTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/MultiPointTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/MultiLineStringTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/MultiPolygonTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/FeatureCollectionTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/BoundingBoxTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/JSONTests.swift
    ${MAPBOX_TURF_TESTS_DIR}/Fixture.swift
)

set(RESOURCE_FILES
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/dc-line.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/featurecollection-no-properties.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/featurecollection.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/geometry-collection.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/multiline.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/multipoint.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/multipolygon.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/point.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/polygon.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/simple-line.geojson
    ${MAPBOX_TURF_TESTS_DIR}/Fixtures/simplify
)

xctest_add_bundle(
    ${FRAMEWORK_TEST_TARGET}
    ${FRAMEWORK_NAME}
    EXCLUDE_FROM_ALL
    ${TEST_SOURCES}
    ${RESOURCE_FILES}
)

set_target_properties(${FRAMEWORK_TEST_TARGET} PROPERTIES
    RESOURCE "${RESOURCE_FILES}"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.mapbox.${FRAMEWORK_TEST_TARGET}"
    XCODE_ATTRIBUTE_WRAPPER_EXTENSION "xctest"
    XCODE_ATTRIBUTE_ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIESS "YES"
)

set_source_files_properties(RESOURCE_FILES PROPERTIES MACOSX_PACKAGE_LOCATION Resources)