import tensorflow as tf

interpreter = tf.lite.Interpreter(model_path="base_model.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input shape:", input_details[0]['shape'])
print("Input dtype:", input_details[0]['dtype'])
