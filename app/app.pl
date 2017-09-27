#!C:\Perl64\bin\perl.exe

    use CGI;
 	use strict;
  	use warnings;
  	use DBI;
  	use Data::Dumper;
    use JSON;
    use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
    use constant APP_URL => "http://localhost:8080/appointment/index.html";

    print CGI::header();
    my $cgi = CGI->new;

        #get all the cgi request parameters
    	my $date = $cgi->param("date");
    	my $time = $cgi->param("time");
    	my $description = $cgi->param("description");
    	my $search = $cgi->param("search");
    	if(not defined $search){
    	    $search = "";
    	}



        #execute insert and select based on request parameters (if there are form inputs then execute insert and redirect, else return JSON based on search text)
    	if(defined $date and defined $time and defined $description){
            my $db = connect_db();
               $db->do('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY ,date TEXT, time TEXT, description TEXT NOT NULL)');

            my $sql = 'insert into appointments (date, time, description) values (?, ?, ?)';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute(
               $date,
               $time,
               $description
            ) or die $sth->errstr;

            $db->disconnect;

             # redirect to application homepage url
             print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=".APP_URL."\">\n";

    	}else{
            my $db = connect_db();
               $db->do('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY ,date TEXT, time TEXT, description TEXT NOT NULL)');
            my $sql = "select date, time, description from appointments WHERE description LIKE '%$search%' order by date desc;";
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute or die $sth->errstr;

           my @output;

             while (my $row = $sth->fetchrow_hashref) {
                push @output, $row;
             }
             $db->disconnect;

             #return JSON
             print to_json(\@output);
    	}

#subroutine for database connection
  	sub connect_db {
          my $dbh = DBI->connect("dbi:SQLite:dbname=appointments.db") or
          die $DBI::errstr;
          return $dbh;
        }

#subroutine for creating table if it doesnt exists
    sub createTable{
                my $db = connect_db();
                $db->do('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY ,date TEXT, time TEXT, description TEXT NOT NULL)');
                $db->disconnect;
            }
