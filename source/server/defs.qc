//
// defs.qc
//

string __fullspawndata;

.entity activator;

entity sky_viewer;
string skyfogcmd;
string skyfogcmd2;

float player_scale;

.string skyname;

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

void(float event, vector value, entity ent) EasyMulticastVector =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
	WriteCoord(MSG_MULTICAST, value_x);
	WriteCoord(MSG_MULTICAST, value_y);
	WriteCoord(MSG_MULTICAST, value_z);
	msg_entity = ent;
	multicast(ent.origin, MULTICAST_ONE_R);
};

void(float event, vector vec, float fl, entity ent) EasyMulticastVecAndFloat =
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, event);
	WriteCoord(MSG_MULTICAST, vec_x);
	WriteCoord(MSG_MULTICAST, vec_y);
	WriteCoord(MSG_MULTICAST, vec_z);
	WriteFloat(MSG_MULTICAST, fl);
	msg_entity = ent;
	multicast(ent.origin, MULTICAST_ONE_R);
};