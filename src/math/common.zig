pub fn Common(comptime Type: type) type {
    return struct {
        pub fn new(e1: f32, e2: f32, e3: f32) Type {
            var result: Type = undefined;

            const fields = @typeInfo(Type).@"struct".fields;
            @field(result, fields[0].name) = e1;
            @field(result, fields[1].name) = e2;
            @field(result, fields[2].name) = e3;

            return result;
        }

        pub fn zero() Type {
            return Type.splat(0);
        }

        pub fn splat(value: f32) Type {
            var result: Type = undefined;
            inline for (@typeInfo(Type).@"struct".fields) |field| {
                @field(result, field.name) = value;
            }
            return result;
        }

        pub fn add(Self: type, Other: type, Return: type) fn (Self, Other) Return {
            return struct {
                pub fn add(self: Self, other: Other) Return {
                    var result: Return = undefined;
                    inline for (@typeInfo(Type).@"struct".fields) |field| {
                        @field(result, field.name) = @field(self, field.name) + @field(other, field.name);
                    }
                    return result;
                }
            }.add;
        }

        pub fn addScalar(self: Type, other: f32) Type {
            var result: Type = undefined;
            inline for (@typeInfo(Type).@"struct".fields) |field| {
                @field(result, field.name) = @field(self, field.name) + other;
            }
            return result;
        }

        pub fn sub(Self: type, Other: type, Return: type) fn (Self, Other) Return {
            return struct {
                pub fn sub(self: Self, other: Other) Return {
                    var result: Return = undefined;
                    inline for (@typeInfo(Type).@"struct".fields) |field| {
                        @field(result, field.name) = @field(self, field.name) - @field(other, field.name);
                    }
                    return result;
                }
            }.sub;
        }

        pub fn subScalar(self: Type, other: f32) Type {
            var result: Type = undefined;
            inline for (@typeInfo(Type).@"struct".fields) |field| {
                @field(result, field.name) = @field(self, field.name) - other;
            }
            return result;
        }

        pub fn mul(self: Type, other: Type) Type {
            var result: Type = undefined;
            inline for (@typeInfo(Type).@"struct".fields) |field| {
                @field(result, field.name) = @field(self, field.name) * @field(other, field.name);
            }
            return result;
        }

        pub fn scale(self: Type, other: f32) Type {
            var result: Type = undefined;
            inline for (@typeInfo(Type).@"struct".fields) |field| {
                @field(result, field.name) = @field(self, field.name) * other;
            }
            return result;
        }
    };
}
