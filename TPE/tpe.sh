#!/bin/bash

echo 'Grupo 12-TPE 2do cuatrimestre 2022'


#The API KEY is stored in an enviroment variable that we use to make the calls
export SPORTRADAR_API='zyyt65pj9m7mbaqr8e2dcduk' 


if [ $# -ne 1 ]
then
	echo "Season id was not be specified"
	exit 1
fi
# season_id = $1 #season_id=sr:season:83837
# If there are any errors we append them to this variable. If it is empty then the program has been executed correctly.
error=""

# We check that season_id has the expected format
echo "$1" | egrep '^(sr:season:[1-9][0-9]{3,4})$' > /dev/null
if [ $? -ne 0 ]
then
	error=$error"<error>season_id must be a valid ID.</error>"
else

    # Before getting the files we check that the id is in seasons.xml
    java net.sf.saxon.Query check_id.xq param_id=$1 -o:found.xml
    echo "<?xml version="1.0" encoding="UTF-8"?>" > aux.xml
    if [ aux = found.xml ]
    then
        # file found.xml does not contain "<found>true<found>", then season_id was not found is seasons.xml
        error=$error"<error>season_id was not found.</error>"
    fi        
fi

# If any error/s occurred, we write it/them to season_data.xml.
if [ "$error" != "" ]
then
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?><season_data xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"season_data.xsd\">$error</season_data>" > "season_data.xml"
    echo "There's been errors during the execution of the program."
else
    api_url="http://api.sportradar.us/soccer/trial/v4/en/seasons/${1}/info.xml?api_key=${SPORTRADAR_API}"
    connection_error="<error>There was an error while trying to reach api.sportradar.us.</error>"
        
    # We attempt to GET both files
    echo "Generating season_info.xml..."
    curl "$api_url" -o season_info.xml

    if [ $? -ne 0 ]
    then
        error=$connection_error
    else
        echo "Generating season_summaries.xml..."
        api_url2="http://api.sportradar.us/soccer/trial/v4/en/seasons/${1}/summaries.xml?api_key=${SPORTRADAR_API}"
        curl "$api_url2" -o season_summaries.xml
        if [ $? -ne 0 ]
        then
            error=$connection_error
        else
            #We delete the namespaces from the generated xml files
            sed 's% xmlns="http://schemas.sportradar.com/sportsapi/soccer/v4"%%' season_info.xml > aux.xml
            rm season_info.xml
            mv aux.xml season_info.xml

            sed 's% xmlns="http://schemas.sportradar.com/sportsapi/soccer/v4"%%' season_summaries.xml > aux.xml
            rm season_summaries.xml
            mv aux.xml season_summaries.xml


            # And use an XQuery to extract the desired data.
            java net.sf.saxon.Query extract_season_data.xq -o:season_data.xml
        fi
    fi
        
    # If any errors occurred during file download we write them in the 
    if [ "$error" != "" ]
    then
        echo "<?xml version=\"1.0\"?><season_data xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"season_data.xsd\">$error</season_data>" > "season_data.xml"
        echo "Errors have occurred during execution."
    fi            
fi

# The markdown page is generated, if there were errors during the execution of the program, they are written in this page
# else, the page displays all the information required 
java net.sf.saxon.Transform -s:season_data.xml -xsl:generate_markdown.xsl -o:season_page.md