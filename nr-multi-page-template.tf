/*  About
    Terraform Multi-page Template 
    Version: 1.0
    Last Modified: 2021-02-19
    Last Modified by: John Hopson
                      johnchopson17@gmail.com
    Created: 2021-02-19
    Created by: John Hopson
	          johnchopson17@gmail.com
    Note: Modified from HashiCorp example (accessed 2021-02-15)
	https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/one_dashboard
    Description: Template for creation of multi-page New Relic One dashboard with summary, KPI & Performance, and Adoption tabs
			tracking various client-specific metrics
*/

resource "newrelic_one_dashboard" "product_dashboard-type_domain" /* sample-product_appname_kpi-adoption_us */ {
  name = "Product Name - App Name: Dashboard Type - Domain"
	    // My Product - My App: KPI & Adoption - US

  // This is the summary dashboard used to surface the most relevant metrics
  page {
    name = "Summary"

    // Adoption section separator
	widget_markdown {
      title = "Dashboard Note"
      row    = 1
      column = 9
	  width = 12

      text = "## Adoption Metrics"
    }
	
	// Displays unique users, devices, and onboarded clients over last 30 days
    widget_billboard {
      title = "Overall Usage"
      row = 2
      column = 1
      width = 6

      nrql_query {
        account_id = <NR Account ID>
        query = "SELECT uniqueCount(userId) as 'Unique Users' ,uniqueCount(deviceId) as 'Unique Devices' ,uniqueCount(clientId) as 'Onboarded Clients' FROM Mobile ,Transaction WHERE <Product-specific WHERE CLAUSE> SINCE 30 day ago"
      }
    }

    // Displays active clients last calendar month
    widget_billboard {
      title = "Active Clients Last Month"
      row = 2
      column = 7
      width = 3

      nrql_query {
        account_id = <NR Account ID>
        query = "SELECT uniqueCount(clientId) AS 'Active Clients' FROM ( SELECT count(*) as 'countedTransactions' FROM Transaction WHERE <Product-specific WHERE CLAUSE> FACET clientId LIMIT MAX ) WHERE countedTransactions > 100 SINCE last month UNTIL this month"
      }
    }

    // Displays users and devices by appName last 30 days
    widget_table {
      title = "Android Users and Devices by App"
      row = 2
      column = 10
      width = 3

      nrql_query {
        account_id = <NR Account ID>
        query = "SELECT uniqueCount(userId) as `Users` ,uniqueCount(deviceId) as 'Devices' FROM Mobile ,Transaction WHERE <Product-specific WHERE CLAUSE> FACET CASES ( WHERE <App-specific GUID-to-Name List> ) AS '<Readable App Name>' ,WHERE appName = <App-specific GUID-to-Name List> ) AS '<Readable App Name>' ,WHERE <App-specific GUID-to-Name List> ) AS '<Readable App Name>' ) AS 'App Name' SINCE 30 days AGO"
      }
    }
  
    // Displays top five clients this week based on users 
    widget_table {
      title = "Top Five Clients by Users"
      row = 3
      column = 1
      width = 5

      nrql_query {
        account_id = <NR Account ID>
        query = "SELECT uniqueCount(userId) as `Users` ,uniqueCount(deviceId) as 'Devices' FROM Mobile ,Transaction WHERE <Product-specific WHERE CLAUSE> FACET CASES ( WHERE <App-specific GUID-to-Name List> ) AS 'App Name' SINCE 30 days AGO"
      }
    }
  }


  // This page contains the details about the KPI and performance metrics surfaced in the summary as well as any others the stakeholders find useful
  page {
    name = "KPI & Performance"

    widget_billboard {
      title = "Requests per minute"
      row = 2
      column = 1

      nrql_query {
        account_id = <NR Account ID>
        query       = "FROM Transaction SELECT rate(count(*), 1 minute)"
      }
    }

    widget_bar {
      title = "Average transaction duration, by application"
      row = 2
      column = 5

      nrql_query {
        account_id = <NR Account ID>
        query       = "FROM Transaction SELECT average(duration) FACET appName"
      }

      // A different dashboard's GUID
      linked_entity_guids = ["abc123"]
    }
  }

  // This page contains the details about the adoption metrics surfaced in the summary as well as any others the stakeholders find useful
  page {
    name = "Adoption"

    widget_billboard {
      title = "Requests per minute"
      row = 2
      column = 1

      nrql_query {
        account_id = <NR Account ID>
        query       = "FROM Transaction SELECT rate(count(*), 1 minute)"
      }
    }

    widget_bar {
      title = "Average transaction duration, by application"
      row = 2
      column = 5

      nrql_query {
        account_id = <NR Account ID>
        query       = "FROM Transaction SELECT average(duration) FACET appName"
      }
    }
  }
}
