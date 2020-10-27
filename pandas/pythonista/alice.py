#!/usr/bin/env python
# coding: utf-8

# In[1]:


from PIL import Image, ImageDraw, ImageFont


# In[8]:


words="""Bruce
care
special
will
string
strong
depending
feel
choice
rabbit 
habit
change
rust
trust
remind
recordings
tells
brightly
right
is
really
me
means
situation
worry
worried
wood
would
egg
repeat
peace
everything
voice
select
control
power
button
scroll"""
words=words.split()


# In[10]:


from os import getcwd,chdir,mkdir,remove


# In[11]:


image_width = 1024
image_height = 760


# In[12]:


startdir=getcwd()
print(startdir)
    


# In[13]:


alist=open("words","w")
for w in words :
    alist.write(w+"\n")
alist.close()


# In[15]:


try:
    font = ImageFont.truetype('Helvetica',size=144)
except:
    font = ImageFont.load_default()
    print(font)
    #print(font.getname())
for w in words :
    print(w)
    try:
        mkdir(w+".dir")
    except:
        pass
    chdir(w+".dir")
    index=1
    img = Image.new('RGB', (image_width, image_height), color=(51, 144, 255))
    # create the canvas
    canvas = ImageDraw.Draw(img)
    text_width, text_height = canvas.textsize(w, font=font)
    #print(f"Text width: {text_width}")
    #print(f"Text height: {text_height}")
    x_pos = int((image_width - text_width) / 2)
    y_pos = int((image_height - text_height) / 2)
    #print(f"X: {x_pos}")
    canvas.text((x_pos, y_pos), w, font=font, fill='#FFFFFF')
    istr="%4.4d" % (index)
    try:
    	remove(istr+".png")
    	remove(istr+".txt")
    except:
    	pass
    img.save(istr+".png")
    tf=open(istr+".txt","w")
    tf.write(w)
    tf.close()
    l=""
    for letter in w:
        l=l+letter
        index=index+1
        img = Image.new('RGB', (image_width, image_height), color=(51, 144, 255))
        # create the canvas
        canvas = ImageDraw.Draw(img)
        text_width, text_height = canvas.textsize(w, font=font)
        #print(f"Text width: {text_width}")
        #print(f"Text height: {text_height}")
        x_pos = int((image_width - text_width) / 2)
        y_pos = int((image_height - text_height) / 2)
        #print(f"X: {x_pos}")
        canvas.text((x_pos, y_pos), l, font=font, fill='#FFFFFF')
        istr="%4.4d" % (index)
        try:
    	     remove(istr+".png")
    	     remove(istr+".txt")
        except:
    	     pass
        img.save(istr+".png")
        tf=open(istr+".txt","w")
        tf.write(letter)
        tf.close()
    for iend in [1,2] :
          index=index+1
          img = Image.new('RGB', (image_width, image_height), color=(51, 144, 255))
    # create the canvas
          canvas = ImageDraw.Draw(img)
          text_width, text_height = canvas.textsize(w, font=font)
    #print(f"Text width: {text_width}")
    #print(f"Text height: {text_height}")
          x_pos = int((image_width - text_width) / 2)
          y_pos = int((image_height - text_height) / 2)
    #print(f"X: {x_pos}")
          canvas.text((x_pos, y_pos), w, font=font, fill='#FFFFFF')
          istr="%4.4d" % (index)
          try:
    	          remove(istr+".png")
    	          remove(istr+".txt")
          except:
    	          pass
          img.save(istr+".png")
          tf=open(istr+".txt","w")
          tf.write(w)
          tf.close()
    thelist=open("list","w")
    for index in range(1,index+1) :
        istr="%4.4d" % (index)
        thelist.write(istr+"\n")
    thelist.close()
    chdir(startdir)


# In[ ]:




