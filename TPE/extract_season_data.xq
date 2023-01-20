<season_data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="season_data.xsd">
    {
    let $season:= doc("season_info.xml")/season_info/season
    return
    <season> 
        <name> {data($season/@name)} </name>
        <competition> {data($season/competition/@name)} </competition>
        <date>
            <start> {data($season/@start_date)} </start>
            <end> {data($season/@end_date)} </end>
            <year> {data($season/@year)} </year>
        </date>
    </season>
    }

    <stages>
    {
        for $stage in doc("season_info.xml")/season_info/stages/stage
        order by $stage/@order
        return        
        <stage phase="{$stage/@phase}" start_date="{$stage/@start_date}" end_date="{$stage/@end_date}">
            <groups>
            {
                for $group in $stage/groups/group
                return
            
                <group>
                {   
                    for $competitor in $group/competitors/competitor 
                    return 
                    <competitor>
                        <name> {data($competitor/@name)} </name>
                        <country> {data($competitor/@country)} </country>
                    </competitor>
                }
                {
                    for $summary in doc("season_summaries.xml")/season_summaries/summary
                    where $group/@id = $summary/sport_event/sport_event_context/groups/group/@id 
                    return
                    <event start_time="{data($summary/sport_event/@start_time)}">
                        <status> {data($summary/sport_event_status/@match_status)} </status>
                        <local> 
                            <name> {data($summary/sport_event/competitors/competitor[./@qualifier="home"]/@name)} </name>
                            <score> {data($summary/sport_event_status/@homes_core)} </score>
                        </local>
                        <visitor>
                            <name> {data($summary/sport_event/competitors/competitor[./@qualifier="away"]/@name)} </name>
                            <score> {data($summary/sport_event_status/@away_score)} </score>
                        </visitor>
                    </event> 
                }
                </group> 
            }
            </groups>
        </stage>
    }
    </stages>
</season_data>