"""This is an example of a git-based profile to instantiate machines to work
with the DORADD artifacts.

This particular profile asks to choose between c6525-100g nodes, c6525-25g nodes
and d6515 nodes; it spawns one server machine and a number of client machines,
and installs all dependencies to run Cornflakes.

Instructions:
Once the Cloudlab UI indicates that the startup scripts have finished running,
please power cycle the machines to load the new Mellanox drivers.
"""

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Emulab extensions.
import geni.rspec.emulab as emulab 

# Create a portal context.
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()
ubuntu_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU22-64-STD'

pc.defineParameter("phystype",
                    "Physical Node Type",
                    portal.ParameterType.STRING,
                    "d6515", 
                    legalValues=["c6525-100g", "d6515", "c6525-25g"]
                    )
pc.defineParameter("numnodes",
                    "Number of nodes to spawn",
                    portal.ParameterType.INTEGER,
                    2 
                    )

pc.defineParameter("sameSwitch",  "No Interswitch Links", portal.ParameterType.BOOLEAN, True)

# Retrieve the values the user specifies during instantiation.
params = pc.bindParameters()
pc.verifyParameters()

## Setup nodes
ip_addrs = ['192.168.1.{}'.format(i + 1) for i in range(params.numnodes)]

# link
link_0 = request.LAN('link-0')
if params.sameSwitch:
    link_0.setNoInterSwitchLinks()
link_0.Site('undefined')
if params.phystype == "c6525-25g":
    link_0.bandwidth = 25000000
else:
    link_0.bandwidth = 100000000
link_0.addComponentManager('urn:publicid:IDN+utah.cloudlab.us+authority+cm')

# Node 0 (client)
node_0 = request.RawPC('client')
node_0.hardware_type = params.phystype
node_0.disk_image = ubuntu_image
iface0 = node_0.addInterface('interface-0', pg.IPv4Address(ip_addrs[0],'255.255.255.0'))
link_0.addInterface(iface0)

nodes = [node_0]

# servers
for i in range(params.numnodes - 1):
    machine_name = "doradd-server{}".format(str(i+1))
    iface_name = "interface-{}".format(str(i+1))
    node = request.RawPC(machine_name)
    node.hardware_type = params.phystype
    node.disk_image = ubuntu_image
    iface = node.addInterface(iface_name, pg.IPv4Address(ip_addrs[i+1],'255.255.255.0'))
    link_0.addInterface(iface)
    nodes.append(node)

nodes[0].addService(pg.Execute(shell="bash", command="/local/repository/setup_client.sh > /tmp/setup1.log 2>&1"))
nodes[1].addService(pg.Execute(shell="bash", command="/local/repository/setup_server1.sh > /tmp/setup1.log 2>&1"))
#nodes[2].addService(pg.Execute(shell="bash", command="/local/repository/setup_server2.sh > /tmp/setup1.log 2>&1"))

# Print the RSpec to the enclosing page.
pc.printRequestRSpec(request)
