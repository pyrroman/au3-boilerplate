#include "bassasio.h"

#include <stdio.h>

void main()
{
	BASS_ASIO_DEVICEINFO di;
	int a;
	for (a=0;BASS_ASIO_GetDeviceInfo(a,&di);a++) {
		printf("dev %d: %s\ndriver: %s\n",a,di.name,di.driver);
		BASS_ASIO_Init(a);
		{
			BASS_ASIO_CHANNELINFO i;
			int b;
			for (b=0;BASS_ASIO_ChannelGetInfo(1,b,&i);b++)
				printf("\tin %d: %s (group %d, format %d)\n",b,i.name,i.group,i.format);
			for (b=0;BASS_ASIO_ChannelGetInfo(0,b,&i);b++)
				printf("\tout %d: %s (group %d, format %d)\n",b,i.name,i.group,i.format);
		}
		BASS_ASIO_Free();
	}
}
