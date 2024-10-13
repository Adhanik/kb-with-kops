
# Why Stateful sets are needed?

- Containers are ephermal in nature(stateless). Once container is delete, Whatever the data is stored in containers is also deleted. For this, we have configured volume, so we can store data in volume to prevent data loss.

- For DB, they will be having host name, along with unique identifiers. Consider we have 3 DB on 3 workernodes DB1, DB2, and DB3, and one of the nodes goes down, resulting in pods alos going down on that node.

- Now if we have not deployed our deployment with the help of stateful sets, our unique identifier (like indexing) and host name for the DB will be changed. The network identities will also be changed. If we had connected any PV to our DB, since the identifier, host name and network identities has changed, there will be no communication btw our DB and PV, which will result in miscommunication btw data.

- To avoid such instances, we are going to deploy our deployment with help of stateful set. Stateful set follows order and index, and hostname does not change, and is imp for DB applications.


