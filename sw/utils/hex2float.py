
def hex_to_float(data, int_bit, point_bit, unmerge):
    int_map = ['0000', '0001', '0010', '0011', '0100', '0101', '0110',
                '0111', '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111']
     decode_bits = int_bit + point_bit
      before_merge = []  # 合併前結果
       for index in range(len(data)):
            # print(data[index])
            # print(len(data[index]))
            for i in range(len(data[index])):
                # pass
                # because one hex bit represent four binary bits -> num(binary) / 4 = num(hex)
                if (i % (decode_bits/4) == 0):
                    before_merge.append('')

        # print("before_merge", before_merge)
        complement_array = before_merge[:]
        # print("complement_array", complement_array)
        index_for_merge = 0
        for index in range(len(data)):
            for i in range(len(data[index])):
                # print(data[index][i])
                if (data[index][i] == '0'):
                    binary_value = int_map[0]
                elif (data[index][i] == '1'):
                    binary_value = int_map[1]
                elif (data[index][i] == '2'):
                    binary_value = int_map[2]
                elif (data[index][i] == '3'):
                    binary_value = int_map[3]
                elif (data[index][i] == '4'):
                    binary_value = int_map[4]
                elif (data[index][i] == '5'):
                    binary_value = int_map[5]
                elif (data[index][i] == '6'):
                    binary_value = int_map[6]
                elif (data[index][i] == '7'):
                    binary_value = int_map[7]
                elif (data[index][i] == '8'):
                    binary_value = int_map[8]
                elif (data[index][i] == '9'):
                    binary_value = int_map[9]
                elif (data[index][i] == 'A'):
                    binary_value = int_map[10]
                elif (data[index][i] == 'B'):
                    binary_value = int_map[11]
                elif (data[index][i] == 'C'):
                    binary_value = int_map[12]
                elif (data[index][i] == 'D'):
                    binary_value = int_map[13]
                elif (data[index][i] == 'E'):
                    binary_value = int_map[14]
                else:
                    binary_value = int_map[15]

                # print(binary_value)

                if (i % (decode_bits/4) != 0):
                    before_merge[index_for_merge] += binary_value
                    index_for_merge += 1
                else:
                    before_merge[index_for_merge] += binary_value

        # print(before_merge)
        is_neg = []
        # =========================== below: doing the 2's complement =====================================
        # for index  in range(len(before_merge)):
        #   for i in range(len(before_merge[index])):
        #     # print(before_merge[index][i])
        #     if(i==0):
        #       if(before_merge[index][i] == '1'):      # represent negative
        #         is_neg += '1'
        #       else:                                 # represent positive
        #         is_neg += '0'
        # =================================================================================================
        for index in range(len(before_merge)):
            rightmost_1_index = -1
            for i in range(len(before_merge[index])-1, -1, -1):
                if (i == 0):
                    if (before_merge[index][i] == '1'):      # represent negative
                        is_neg += '1'
                    else:                                 # represent positive
                        is_neg += '0'
                if (before_merge[index][i] == '1' and rightmost_1_index == -1):
                    rightmost_1_index = i

            # print(rightmost_1_index)
            if (is_neg[index] == '1'):
                for i in range(0, rightmost_1_index, 1):
                    if (before_merge[index][i] == '1'):
                        complement_array[index] += '0'
                    else:
                        complement_array[index] += '1'
                for i in range(rightmost_1_index, len(before_merge[index]), 1):
                    if (before_merge[index][i] == '1'):
                        complement_array[index] += '1'
                    else:
                        complement_array[index] += '0'
            else:
                for i in range(len(before_merge[index])):
                    complement_array[index] += before_merge[index][i]

        # print("@@#%$#@%$#@%$#@5")
        # print(complement_array)
        # print(is_neg)
    # ====================finish 2's complement , do the transform====================
        result = ['' for data_num in range(len(complement_array))]

        for index in range(len(complement_array)):
            # print("index:", index)
            int_part = 0
            point_part = 0
            for i in range(0, int_bit, 1):
                int_part += int(complement_array[index]
                                [i]) * (2 ** (int_bit-1-i))

            pow = -1

            for i in range(int_bit, len(complement_array[index]), 1):
                # print(i)
                point_part += int(complement_array[index][i]) * (2 ** (pow))
                pow -= 1

            # print("int_part:", int_part)
            # print("point_part :", point_part)

            if (is_neg[index] == '1'):
                result[index] = (int_part + point_part) * -1
            else:
                result[index] = (int_part + point_part)
            # print(result)

        return result
