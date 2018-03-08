import subprocess
import sys

struct = str(sys.argv[1])
func = str(sys.argv[2])
output = str(sys.argv[3])

func_min, func_max = subprocess.check_output(' '.join(['fslstats',func,'-r']), shell = True).split('\n')[0].split(' ')[:2]
func_range = float(func_max) - float(func_min)

struct_min, struct_max = subprocess.check_output(' '.join(['fslstats',struct,'-R']), shell = True).split('\n')[0].split(' ')[:2]
struct_range = float(struct_max) - float(struct_min)

mul = (func_range / struct_range) * -1
add_num = float(struct_max) * float(mul)
if add_num < 0:
    add_num = add_num * -1
add = add_num + float(func_min)

print('STRUCT:', struct)
print('FUNC:', func)
print('OUTPUT:', output)

print('FUNC_MIN:', func_min)
print('FUNC_MAX:', func_max)
print('FUNC_RANGE:', func_range)
print('STRUCT_MIN:', struct_min)
print('STRUCT_MAX:', struct_max)
print('STRUCT_RANGE:', struct_range)
print('MUL:', mul)
print('ADD_NUM:', add_num)
print('ADD:', add)

subprocess.check_call(' '.join(['fslmaths',str(struct),'-mul',str(mul),'-add',str(add),output]), shell = True)
