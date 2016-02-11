import ddf.minim.*;

class Chimes {
  Minim minim;
  AudioSample[] chime;
  int scene = 1;
  int numSamples = 12;
  int numScenes = 3;

  Chimes(Minim m) {
    minim = m;
    chime = new AudioSample[numSamples*numScenes];
    loadScene();
  }

  void loadScene() {
    // dancer 1, scene 1
    chime[0] = minim.loadSample( "01_C_Major_Light_No Reverb/01-C.wav", 512);
    chime[1] = minim.loadSample( "01_C_Major_Light_No Reverb/02-D.wav", 512);
    chime[2] = minim.loadSample( "01_C_Major_Light_No Reverb/03-E.wav", 512);
    chime[3] = minim.loadSample( "01_C_Major_Light_No Reverb/04-G.wav", 512);
    chime[4] = minim.loadSample( "01_C_Major_Light_No Reverb/05-A.wav", 512);
    chime[5] = minim.loadSample( "01_C_Major_Light_No Reverb/06-C.wav", 512);
    chime[6] = minim.loadSample( "01_C_Major_Light_No Reverb/07-D.wav", 512);
    // dancer 2, scene 1
    chime[7] = minim.loadSample( "01_C_Major_Light_No Reverb/01-C.wav", 512);
    chime[8] = minim.loadSample( "01_C_Major_Light_No Reverb/08-E.wav", 512);
    chime[9] = minim.loadSample( "01_C_Major_Light_No Reverb/09-G.wav", 512);
    chime[10] = minim.loadSample( "01_C_Major_Light_No Reverb/10-A.wav", 512);
    chime[11] = minim.loadSample( "01_C_Major_Light_No Reverb/06-C.wav", 512);

    // dancer 1, scene 2
    chime[12] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/01-C.wav", 512);
    chime[13] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/02-Eb.wav", 512);
    chime[14] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/03-F.wav", 512);
    chime[15] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/04-G.wav", 512);
    chime[16] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/05-Bb.wav", 512);
    chime[17] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/06-C.wav", 512);
    chime[18] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/07-Eb.wav", 512);
    // dancer 2, scene 2
    chime[19] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/01-C.wav", 512);
    chime[20] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/08-F.wav", 512);
    chime[21] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/09-G.wav", 512);
    chime[22] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/10-Bb.wav", 512);
    chime[23] = minim.loadSample( "02_C_Minor _Medium_Light Reverb/06-C.wav", 512);

    // dancer 1, scene 3
    chime[24] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/01-C.wav", 512);
    chime[25] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/02-D.wav", 512);
    chime[26] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/03-E.wav", 512);
    chime[27] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/04-G.wav", 512);
    chime[28] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/05-A.wav", 512);
    chime[29] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/06-C.wav", 512);
    chime[30] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/07-D.wav", 512);
    // dancer 2, scene 3
    chime[31] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/01-C.wav", 512);
    chime[32] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/08-E.wav", 512);
    chime[33] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/09-G.wav", 512);
    chime[34] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/10-A.wav", 512);
    chime[35] = minim.loadSample( "03_C_Major_Heavy_Big_Reverb/06-C.wav", 512);
  }


  void setScene(int s) {
    scene = s;
  }

  void playChime(int ch) {
    //println((numSamples*(scene-1)) + ch);
    chime[numSamples*(scene-1)+ch].trigger();
  }
}