declare variable $param_id external;

for $season in doc("seasons.xml")/seasons/season
where $season/@id = $param_id 
return
<found> true </found>