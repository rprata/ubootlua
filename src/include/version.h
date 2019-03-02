#ifndef __VERSION_H__
#define __VERSION_H__

#ifdef __cplusplus
extern "C" {
#endif

#define VERSION "0.1"

#define BANNER_VERSION (" ___________________________________\n" \
						"/ Hi guys. I'm a modern extensible \\\n" \
						"\\ bootloader with Lua support.     /\n" \
						" -----------------------------------\n" \
						"  \\    ____________ 				 \n" \
						"   \\   |__________|					 \n" \
						"      /           /\\				 \n" \
						"     /           /  \\				 \n" \
						"    /___________/___/|				 \n" \
						"    |          |     |				 \n" \
						"    |  ==\\ /== |     |				 \n" \
						"    |   O   O  | \\ \\ |			 \n" \
						"    |     <    |  \\ \\|			 \n" \
						"   /|          |   \\ \\			 \n" \
						"  / |  \\_____/ |   / /			 \n" \
						" / /|          |  / /|				 \n" \
						"/||\\|          | /||\\/			 \n" \
						"    -------------|   				 \n" \
						"        | |    | | 				 \n" \
						"       <__/    \\__>				 \n" \
						"(C) 2019 - Version "VERSION"  		 \n")

#define SZ_BANNER_VERSION 814

const char * version(void);
const char * banner_version(void);

#ifdef __cplusplus
}
#endif

#endif /* __VERSION_H__ */
