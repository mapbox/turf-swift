[GeoJson
-|.json
-|---
-|/*Decode an unknown GeoJSON object.
-|"let"
-|geojson 
-|= 
-|try 
-|*/
[JSONDecoder
-|()]*/
-{
-|}.decode(
-|*/
-|---
[GeoJSONObject
-|.self, from: data)
-|guard 
-|case let 
-|.feature(feature) 
-|= geojson,
-|case let 
-|.point(point) 
-|= feature
-|.geometry 
-|else 
{
-|return
-|]={
}
-|
[Decode a known GeoJSON object.
-|let 
-|featureCollection 
-|= 
-|try 
-|JSONDecoder
-|()
-|.decode(FeatureCollection
-|.self, 
-|from: 
-|data)
-|
[Initialize a Point feature and encode it as GeoJSON.
-|let 
-|coordinate = 
-|CLLocationCoordinate2D(latitude: 
-|0, longitude: 
-|1)
-|let 
-|point = 
-|Point(coordinate)
-|let pointFeature = Feature(geometry: .point(point))
-|let data = try JSONEncoder().encode(pointFeature)
-|let json = String(data: data, encoding: .utf8)
-|print(json)
-|
-[-
-|#
-|'/*]}
-|{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [
      1,
      0
    ]
  }
}
-|*/'#}]
