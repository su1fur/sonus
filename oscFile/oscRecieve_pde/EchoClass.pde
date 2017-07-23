class EchoClass implements AudioEffect
{
  float[] l_buffer;
  float[] r_buffer;
  int buffer_size;
  int l_index, r_index;
  float delay_time;
  int feedback;
  float[] delay_level;
  
  EchoClass(float fs, float dt, float dl, int fb)
  {
    delay_time = fs * dt;
    feedback = fb;
    buffer_size = (int)(delay_time * feedback) + 256;
    
    l_index = 0;
    r_index = 0;
    
    l_buffer = new float[buffer_size];
    r_buffer = new float[buffer_size];
    
    for (int i = 0; i < buffer_size; i++)
    {
      l_buffer[i] = 0.0;
      r_buffer[i] = 0.0;
    }
    
    delay_level = new float[feedback];
    
    for (int i = 0; i < feedback; i++)
    {
      delay_level[i] = pow(dl, (float)(i + 1) );
    }
  }
  
  int echo_process(float[] samp, float[] buffer, int ix)
  {
    int index = ix;
    float[] out = new float[samp.length];
    for ( int n = 0; n < samp.length; n++ )
    {
      buffer[index] = samp[n];
      float data = samp[n];
      for (int i = 0; i < feedback; i++)
      {
        int m = index - (int)((i + 1) * delay_time);
        if ( m < 0 )
        {
          m += buffer_size;
        }
        data += delay_level[i] * buffer[m];
      }
      out[n] = data;
      index++;
      if (index >= buffer_size)
      {
        index = 0;
      }
    }    
    arraycopy(out, samp);
    
    return index;
  }

  void process(float[] samp)
  {
    l_index = echo_process(samp, l_buffer, l_index);
  }
  
  void process(float[] left, float[] right)
  {
    l_index = echo_process(left, l_buffer, l_index);
    r_index = echo_process(right, r_buffer, r_index);
  }
}