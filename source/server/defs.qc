//
// defs.qc
//

string __fullspawndata;

.entity activator;

//
// MULTICAST FUNCTIONS
//

void(float event, float value, entity ent) EasyMulticastFloat =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
	WriteFloat(MSG_MULTICAST, value);
	msg_entity = ent;
	multicast(ent.origin, MULTICAST_ONE_R);
};

void(float event, string value, entity ent) EasyMulticastString =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
	WriteString(MSG_MULTICAST, value);
	msg_entity = ent;
	multicast(ent.origin, MULTICAST_ONE_R);
};