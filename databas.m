javaaddpath([matlabroot,'/java/jarext/mysql-connector-java-8.0.19.jar'])
conn=database('berlindb','berlinuname','berlinpass','com.mysql.jdbc.Driver','jdbc:mysql://db4free.net:3306/berlindb');
query=exec(conn,'select * from identity');
query=fetch(query);
query.Data;
display(query.Data);